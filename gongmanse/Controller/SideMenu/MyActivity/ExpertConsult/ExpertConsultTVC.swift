import UIKit
import BottomPopup

protocol ExpertConsultTVCDelegate: AnyObject {
    func expertConsultPassSortedIdSettingValue(_ expertConsultSortedIndex: Int)
}

class ExpertConsultTVC: UITableViewController, BottomPopupDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var pageIndex: Int!
    var expertConsult: ExpertModels?
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var delegate: ExpertConsultTVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromJson()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(expertConsultFilterNoti(_:)), name: NSNotification.Name("expertConsultFilterText"), object: nil)
        
    }
    
    @objc func expertConsultFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "expertConsultFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/member/myconsultation?token=\(Constant.token)&offset=0&limit=20&sort_id=4") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(ExpertModels.self, from: data) {
                    //print(json.body)
                    self.expertConsult = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.expertConsult else { return }
        
        self.countAll.text = "총 \(value.totalNum)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: value.totalNum))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: value.totalNum))
        
        self.countAll.attributedText = attributedString
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "ExpertConsultBottomPopUpVC") as! ExpertConsultBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.expertConsult else { return 0 }
        if value.totalNum == "0" {
            return 1
        } else {
            guard let data = self.expertConsult?.data else { return 0}
            return data.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let value = self.expertConsult else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "질문 목록이 없습니다."
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultTVCell") as! ExpertConsultTVCell
            
            guard let json = self.expertConsult else { return cell }
            
            let indexData = json.data[indexPath.row]
            let defaultURL = fileBaseURL
            guard let thumbnailURL = indexData.sFilepaths else { return UITableViewCell() }
            let url = URL(string: makeStringKoreanEncoded(defaultURL + "/" + thumbnailURL))
            let profileImageURL = indexData.sProfile ?? ""
            let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
            
            cell.consultThumbnail.contentMode = .scaleAspectFill
            cell.consultThumbnail.sd_setImage(with: url)
            cell.consultTitle.text = indexData.sQuestion
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.expertConsult else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ExpertConsultTVC: ExpertConsultBottomPopUpVCDelegate {
    func expertConsultPassSortedIdRow(_ expertConsultSortedIdRowIndex: Int) {
        
        if expertConsultSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if expertConsultSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else if expertConsultSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2
        } else {                            // 4 번째 Cell
            self.sortedId = 3
        }
        
        self.delegate?.expertConsultPassSortedIdSettingValue(expertConsultSortedIdRowIndex)
        self.tableView.reloadData()
    }
}
