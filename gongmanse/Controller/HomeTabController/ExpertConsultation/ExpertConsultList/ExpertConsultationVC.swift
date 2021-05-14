import UIKit
import BottomPopup

protocol ExpertConsultationVCDelegate: class {
    func expertConsultationPassSortedIdSettingValue(_ sortedIndex: Int)
}

class ExpertConsultationVC: UIViewController, BottomPopupDelegate, ExpertConsultationVCDelegate {
    func expertConsultationPassSortedIdSettingValue(_ sortedIndex: Int) {
        self.expertConsultSortedIndex = sortedIndex
    }
    
    var expertConsultSortedIndex: Int = 0
    var consultModels: ExpertModels?
    var delegate: ExpertConsultationVCDelegate?
    
    var height: CGFloat = 200
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var expertConsultationTV: UITableView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromJson()
        naviAndLabelSettings()
        floatingButton()
        
        //테이블 뷰 빈칸 숨기기
        expertConsultationTV.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sortFilterNoti(_:)), name: NSNotification.Name("consultFilterText"), object: nil)
        
        delegate = self
        self.sortedId = expertConsultSortedIndex
    }
    
    @objc func sortFilterNoti(_ sender: NotificationCenter) {
        let sortedButtonTitle = UserDefaults.standard.object(forKey: "consultFilterText")
        filteringBtn.setTitle(sortedButtonTitle as? String, for: .normal)
    }
    
    func naviAndLabelSettings() {
        
        //총 개수 label text 지정
        countAll.text = "총 56개"
        //상담하기 썸네일 총 개수 label 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: "56"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: "56"))
        
        self.countAll.attributedText = attributedString
    }
    
    func getDataFromJson() {
        if let url = URL(string: ExpertConsultation_URL + "limit=57&offset=0&sort_id=\(sortedId ?? 4)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(ExpertModels.self, from: data) {
                    //print(json.body)
                    self.consultModels = json
                }
                DispatchQueue.main.async {
                    self.expertConsultationTV.reloadData()
                }
            }.resume()
        }
    }
    
    @IBAction func selectMenuBtn(_ sender: UIButton) {
        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationBottomPopUpVC") as! ExpertConsultationBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                                                           toItem: view,
                                                           attribute: .bottom,
                                                           multiplier: 0.89,
                                                           constant: 0)])
    }
    
    @objc func buttonTapped() {
        let floatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationFloatingVC") as! ExpertConsultationFloatingVC
        self.navigationController?.pushViewController(floatingVC, animated: true)
    }
}

extension ExpertConsultationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.consultModels?.data else { return 0 }
        return data.count
        //        guard let data = self.consultModels?.body else { return 0 }
        //        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultationTVCell") as! ExpertConsultationTVCell
        
        guard let json = self.consultModels else { return cell }
        
        let indexData = json.data[indexPath.row]
        let defaultLink = fileBaseURL
        let thumbnailImageURL = indexData.sFilepaths ?? ""
        let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
        let profileImageURL = indexData.sProfile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        
        cell.consultThumbnail.contentMode = .scaleAspectFill
        cell.consultThumbnail.sd_setImage(with: thumbnailURL)
        cell.consultTitle.text = indexData.sQuestion?.htmlEscaped
        cell.nickName.text = indexData.sNickname
        cell.answerStatus.text = indexData.iAnswer
        cell.profileImage.contentMode = .scaleAspectFill
        cell.upLoadDate.text = indexData.dtRegister
        
        if indexData.iAnswer == "1" {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.answerStatus.text = "답변 완료 >"
        } else {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
            cell.answerStatus.text = "대기중 >"
        }
        
        DispatchQueue.main.async {
            if profileImageURL == ""{
                cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
            }else {
                cell.profileImage.sd_setImage(with: profileURL)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationDetailVC") as! ExpertConsultationDetailVC
        vc.receiveData = consultModels?.data[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension ExpertConsultationVC: ExpertConsultationBottomPopUpVCDelegate {
    func passSortedIdRow(_ sortedIdRowIndex: Int) {
        
        if sortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 4 // 평점순
        } else if sortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 5 // 최신순
        } else if sortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 6 // 이름순
        } else {                            // Default 값
            self.sortedId = 4 // 최신순
        }
        
        self.delegate?.expertConsultationPassSortedIdSettingValue(sortedIdRowIndex)
        self.expertConsultationTV.reloadData()
    }
}
