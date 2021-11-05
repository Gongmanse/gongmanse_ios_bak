import UIKit
import BottomPopup
import Alamofire

protocol RecentVideoVCDelegate: AnyObject {
    func recentVideoPassSortedIdSettingValue(_ recentVideoSortedIndex: Int)
}

class RecentVideoTVC: UITableViewController, BottomPopupDelegate {
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    @IBOutlet weak var autoPlayLabel: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    
    var ticket: SideMenuHeaderViewModel?
    
    var inputSortNum = 4
    
    var isDeleteMode: Bool = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var pageIndex: Int!
    var recentViedo: FilterVideoModels?
    var tableViewInputData: [FilterVideoData] = []
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            self.tableViewInputData.removeAll()
            self.tableView.reloadData()
            getDataFromJson(offset: 0)
        }
    }
    var isLoading = false
    
    var delegate: RecentVideoVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
//        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        let tableViewLoadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "LoadingCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(recentVideoFilterNoti(_:)), name: NSNotification.Name("recentVideoFilterText"), object: nil)
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        autoPlayLabel.textColor = UIColor.black
        
        getDataFromJson(offset: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteMode = true
        
//        playSwitch.isOn = autoPlayDataManager.isAutoplayRecentTab
    }
    
    
    @objc func recentVideoFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "recentVideoFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson(offset: Int) {
        print("Recent getDataFromJson : \(offset)")
        isLoading = true
        
        switch sortedId {
        case 0:
            inputSortNum = 4
        case 1:
            inputSortNum = 1
        case 2:
            inputSortNum = 2
        case 3:
            inputSortNum = 3
        default:
            inputSortNum = 4
        }
        
        if let url = URL(string: "\(apiBaseURL)/v/member/watchhistory?token=\(Constant.token)&sort_id=\(inputSortNum)&offset=\(offset)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.tableViewInputData.append(contentsOf: json.data)
                    self.recentViedo = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings(Int(self.recentViedo?.totalNum ?? "0") ?? 0)
                }
                
            }.resume()
        }
    }
    
    func textSettings(_ totalNum: Int) {
        
        let strCount = String(totalNum).withCommas()
        self.countAll.text = "총 \(strCount)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: String(totalNum)))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: strCount))
        
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
        guard let value = self.recentViedo else { return 0 }
        
        if value.totalNum == "0" {
            return 1
        } else {
            return tableViewInputData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.recentViedo else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "영상 목록이 없습니다."
            cell.selectionStyle = .none
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentVideoTVCell") as! RecentVideoTVCell
            
            guard let _ = self.recentViedo else { return cell }
            
            let indexData = self.tableViewInputData[indexPath.row]
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
            
            cell.deleteButton.isHidden = isDeleteMode
            cell.deleteView.isHidden = isDeleteMode
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let _ = self.recentViedo else { return }
        guard let id = self.tableViewInputData[sender.tag].id else { return }
        
        let inputData = RecentVideoInput(id: id)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        
        
        RecentVideoTVCDataManager().postRemoveRecentVideo(param: inputData, viewController: self)
    }
    
    @IBAction func autoplaySwitch(_ sender: UISwitch) {
                
        if playSwitch.isOn {
            autoPlayLabel.textColor = UIColor.black
        } else {
            autoPlayLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.recentViedo else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = self.recentViedo else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if value.totalNum == "0" {
//            presentAlert(message: "영상 목록이 없습니다.")
            return
        }
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            
            presentAlert(message: "이용권을 구매해주세요")
            
        } else {
            
            var inputArr = [VideoModels]()
            
            guard let receivedData = recentViedo else { return }
            
            for dataIndex in tableViewInputData.indices {
                
                let data = tableViewInputData[dataIndex]
                
                let inputData = VideoModels(seriesId: data.iSeriesId,
                                            videoId: data.video_id,
                                            title: data.sTitle,
                                            tags: data.sTags,
                                            teacherName: data.sTeacher,
                                            thumbnail: data.sThumbnail,
                                            subject: data.sSubject,
                                            subjectColor: data.sSubjectColor,
                                            unit: data.sUnit,
                                            rating: data.iRating,
                                            isRecommended: "",
                                            registrationDate: "",
                                            modifiedDate: "",
                                            totalRows: "")
                inputArr.append(inputData)
            }
            
            autoPlayDataManager.currentViewTitleView = "최근영상"
            autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
            autoPlayDataManager.videoDataList.removeAll()
            autoPlayDataManager.videoDataList.append(contentsOf: inputArr)
            autoPlayDataManager.videoSeriesDataList.removeAll()
            autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
            autoPlayDataManager.currentSort = self.sortedId ?? 0
            
            if receivedData.totalNum == "0" {
                presentAlert(message: "영상 목록이 없습니다.")
            } else {
                let vc = VideoController()
                vc.modalPresentationStyle = .fullScreen
                let videoID = tableViewInputData[indexPath.row].video_id
                vc.id = videoID
                present(vc, animated: true)
            }
        }
    }
    
    //0711 - added by hp
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.tableViewInputData.count - 1 && !self.isLoading
            && self.tableViewInputData.count < (Int(self.recentViedo?.totalNum ?? "0") ?? 0) {
            //더보기
            getDataFromJson(offset: self.tableViewInputData.count)
        }
    }
}

extension RecentVideoTVC: RecentVideoBottomPopUpVCDelegate {    
    func recentPassSortedIdRow(_ recentSortedIdRowIndex: Int) {
        
        if recentSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0 //최신
        } else if recentSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1 //이름
        } else if recentSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2 //과목
        } else {                            // 4 번째 Cell
            self.sortedId = 3 //평점
        }
        
        self.delegate?.recentVideoPassSortedIdSettingValue(recentSortedIdRowIndex)
        self.tableView.reloadData()
    }
}


// MARK: - API

extension RecentVideoTVC {
    func didSuccessPostAPI() {
        
        self.textSettings((Int(self.recentViedo?.totalNum ?? "0") ?? 0) - 1)
        //self.tableView.reloadData()
        self.view.layoutIfNeeded()
    }
}


struct RecentVideoInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class RecentVideoTVCDataManager {
    
    func postRemoveRecentVideo(param: RecentVideoInput, viewController: RecentVideoTVC) {
        
        let id = param.id
        
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(id)".data(using: .utf8)!, withName: "history_id")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            
        }, to: "\(apiBaseURL)/v/member/watchhistory").response { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
                viewController.didSuccessPostAPI()
                print(response)
            case.failure:
                print("error")
            }
        }
        
    }
}
