import UIKit
import BottomPopup

class ExpertConsultationVC: UIViewController, BottomPopupDelegate {
    
    var consultModels: ExpertModels?
    var consultModelData: [ExpertModelData] = []
    
    var height: CGFloat = 200
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
//    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var expertConsultationTV: UITableView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        let indexPath = NSIndexPath(row: NSNotFound, section: 0)
        expertConsultationTV.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    
    var sortedId: Int = 4
    
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getDataFromJson()
//        floatingButton()
        
        self.addBtn.imageView?.contentMode = .scaleAspectFill
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
            self.addBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
        
        //테이블 뷰 빈칸 숨기기
        expertConsultationTV.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sortFilterNoti(_:)), name: NSNotification.Name("consultFilterText"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.consultModelData.removeAll()
        self.expertConsultationTV.reloadData()
        
        getDataFromJson()
    }
    
    @objc func sortFilterNoti(_ sender: NotificationCenter) {
        let sortedButtonTitle = UserDefaults.standard.object(forKey: "consultFilterText")
        filteringBtn.setTitle(sortedButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
        if let url = URL(string: ExpertConsultation_URL + "limit=20&offset=\(consultModelData.count)&sort_id=\(sortedId)") {
            isLoading = true
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(ExpertModels.self, from: data) {
//                    print(json.data)
                    self.consultModels = json
                    self.consultModelData.append(contentsOf: json.data)
                }
                DispatchQueue.main.async {
                    self.expertConsultationTV.reloadData()
                    self.textSettings()
                }
            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.consultModels?.totalNum else { return }
        
        let strCount = value.withCommas()
        self.countAll.text = "총 \(strCount)개"
        self.countAll.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.black])

        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (countAll.text! as NSString).range(of: strCount))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: strCount))

        self.countAll.attributedText = attributedString
    }
    
    @IBAction func selectMenuBtn(_ sender: UIButton) {
        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationBottomPopUpVC") as! ExpertConsultationBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId - 4
        present(popupVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        //다른 뷰 영향 받지 않고 무조건 탭 바 보이기
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //플로팅 버튼 생성 및 크기 지정 후 뷰 이동
    func floatingButton() {
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        btn.setImage(UIImage(named: "floatingBtn"), for: .normal)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                                        
                                        NSLayoutConstraint(item: btn,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: view,
                                                           attribute: .trailing,
                                                           multiplier: 1,
                                                           constant: -15),
                                        
                                        NSLayoutConstraint(item: btn,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: view.safeAreaLayoutGuide,
                                                           attribute: .bottom,
                                                           multiplier: 1,
                                                           constant: -15)])
    }
    
//    @objc func buttonTapped() {
    @IBAction func buttonTapped(_ sender: Any) {
        if !Constant.isLogin {
            let alert = UIAlertController(title: "로그인", message: "로그인이 필요한 서비스 입니다. 로그인 하시겠습니까?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "확인", style: .default) { (_) in
                let vc = LoginVC(nibName: "LoginVC", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        let floatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationFloatingVC") as! ExpertConsultationFloatingVC
        floatingVC.floatingDelegate = self
        self.navigationController?.pushViewController(floatingVC, animated: true)
    }
}

extension ExpertConsultationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consultModelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultationTVCell") as! ExpertConsultationTVCell
        
        guard let _ = self.consultModels else { return cell }
        
        let indexData = consultModelData[indexPath.row]
        let defaultLink = fileBaseURL
        let thumbnailImageURL = indexData.sFilepaths ?? ""
        let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
        let profileImageURL = indexData.sProfile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        
        cell.consultTitle.text = indexData.sQuestion?.htmlEscaped.trimmingCharacters(in: .whitespacesAndNewlines)// 문장 시작과 끝의 공백&줄바꿈 제거
        
        cell.nickName.text = indexData.sNickname
        cell.answerStatus.text = indexData.iAnswer
        cell.profileImage.contentMode = .scaleAspectFill
        cell.upLoadDate.text = indexData.simpleDt
        
        if indexData.iAnswer == "1" {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.answerStatus.text = "답변 완료 >"
        } else {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
            cell.answerStatus.text = "대기중 >"
        }
        
        DispatchQueue.main.async {
            cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
            if profileImageURL != "" {
                cell.profileImage.sd_setImage(with: profileURL)
            }
            
            if indexData.sFilepaths == nil {
                cell.consultThumbnail.contentMode = .scaleAspectFit
                cell.consultThumbnail.image = UIImage(named: "app_icon")
            } else {
                cell.consultThumbnail.contentMode = .scaleAspectFill
                cell.consultThumbnail.sd_setImage(with: thumbnailURL) { img, err, type, URL in
                    if img == nil {
                        cell.consultThumbnail.contentMode = .scaleAspectFit
                        cell.consultThumbnail.image = UIImage(named: "app_icon")
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationDetailVC") as! ExpertConsultationDetailVC
        vc.receiveData = consultModelData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.frame.height < cell.frame.height * CGFloat(indexPath.row) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == self.consultModelData.count - 1 && !isLoading
            && self.consultModelData.count < (Int(consultModels?.totalNum ?? "0") ?? 0) {
            //더보기
            getDataFromJson()
        }
    }
}

/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension ExpertConsultationVC: ExpertConsultationBottomPopUpVCDelegate, ExpertConsultationFloatingVCDelegate {
    func sendButtonSelected(completion: @escaping () -> Void) {
        self.consultModelData.removeAll()
        self.expertConsultationTV.reloadData()
        getDataFromJson()
        
        completion()
    }

    
    func passSortedIdRow(_ sortedIdRowIndex: Int) {
        
        if sortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 4 // 최신순
        } else if sortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 5 // 조회순
        } else if sortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 6 // 답변완료순
        } else {                            // Default 값
            self.sortedId = 4 // 최신순
        }
        
        self.consultModelData.removeAll()
        self.expertConsultationTV.reloadData()
        
        getDataFromJson()
    }
}
