import UIKit
import BottomPopup

protocol ExpertConsultationVCDelegate: class {
    func expertConsultationPassSortedIdSettingValue(_ sortedIndex: Int)
}

class ExpertConsultationVC: UIViewController, BottomPopupDelegate {
    
    private var refreshControl = UIRefreshControl()
    
    var consultModels: VideoInput?
    
    var delegate: ExpertConsultationVCDelegate?

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var ExpertConsultationTV: UITableView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    var selectedItem: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
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
        ExpertConsultationTV.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sortFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
    }
    
    @objc func sortFilterNoti(_ sender: NotificationCenter) {
        let sortedButtonTitle = UserDefaults.standard.object(forKey: "rateFilterText")
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
        if let url = URL(string: ExpertConsultation_URL + "offset=0&limit=56") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //print(json.body)
                    self.consultModels = json
                }
                DispatchQueue.main.async {
                    self.ExpertConsultationTV.reloadData()
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
        popupVC.selectItem = self.selectedItem
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
        btn.frame = CGRect(x: 320, y: 695, width: 68, height: 68)
        btn.setImage(UIImage(named: "floatingBtn"), for: .normal)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func buttonTapped() {
        let floatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationFloatingVC") as! ExpertConsultationFloatingVC
        self.navigationController?.pushViewController(floatingVC, animated: true)
    }
}

extension ExpertConsultationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.consultModels?.body else { return 0 }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cellId = row.question == consultTitle.numberOfRowsInSection = 0 ? "ExpertConsultationVC" : "ExpertConsultationTwoLines"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultationTVCell") as! ExpertConsultationTVCell
        
        guard let json = self.consultModels else { return cell }
        
        let indexData = json.body[indexPath.row]
        let url = URL(string: indexData.thumbnail ?? "nil")
        let profileImageURL = indexData.profile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        
        cell.consultThumbnail.contentMode = .scaleAspectFill
        cell.consultThumbnail.sd_setImage(with: url)
        cell.consultTitle.text = indexData.question
        cell.nickName.text = indexData.nickname
        cell.answerStatus.text = indexData.answerComplete
        cell.profileImage.contentMode = .scaleAspectFill
//        cell.profileImage.sd_setImage(with: profileURL)
        cell.upLoadDate.text = indexData.registerDate
        
        if indexData.answerComplete == "1" {
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension ExpertConsultationVC: ExpertConsultationBottomPopUpVCDelegate {
    func passSortedIdRow(_ sortedIdRowIndex: Int) {
        self.delegate?.expertConsultationPassSortedIdSettingValue(sortedIdRowIndex)
        self.ExpertConsultationTV.reloadData()
    }
}
