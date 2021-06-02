import UIKit
import BottomPopup

protocol RecentVideoVCDelegate: AnyObject {
    func recentVideoPassSortedIdSettingValue(_ recentVideosortedIndex: Int)
}

class RecentVideoTVC: UITableViewController, BottomPopupDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var pageIndex: Int!
    var recentViedo: FilterVideoModels?
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var delegate: RecentVideoVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        getDataFromJson()
        
        let tableViewLoadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "LoadingCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("recentVideoFilterText"), object: nil)
        
    }
    
    @objc func videoFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "recentVideoFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/member/watchhistory?token=\(Constant.token)&sort_id=\(sortedId ?? 4)&offset&limit") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.recentViedo = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        
        guard let value = self.recentViedo else { return }
        
        self.countAll.text = "총 \(value.totalNum ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        
        self.countAll.attributedText = attributedString
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "RecentVideoBottomPopUpVC") as! RecentVideoBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.recentViedo?.data else { return 0}
        return data.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentVideoTVCell") as! RecentVideoTVCell
        
        guard let json = self.recentViedo else { return cell }
        
        let indexData = json.data[indexPath.row]
        let defaultURL = fileBaseURL
        guard let thumbnailURL = indexData.sThumbnail else { return UITableViewCell() }
        let url = URL(string: makeStringKoreanEncoded(defaultURL + "/" + thumbnailURL))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.teachersName.text = (indexData.sTeacher ?? "nil") + " 선생님"
        cell.upLoadDate.text = indexData.dtTimestamp
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor ?? "nil")
        
        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RecentVideoTVC: RecentVideoBottomPopUpVCDelegate {
    func recentPassSortedIdRow(_ recentSortedIdRowIndex: Int) {
        
        if recentSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if recentSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else if recentSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2
        } else {                            // 4 번째 Cell
            self.sortedId = 3
        }
        
        
        self.delegate?.recentVideoPassSortedIdSettingValue(recentSortedIdRowIndex)
        self.tableView.reloadData()
    }
}
