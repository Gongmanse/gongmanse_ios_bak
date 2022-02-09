import UIKit
import BottomPopup
import Alamofire

protocol RecentVideoVCDelegate: AnyObject {
    func recentVideoPassSortedIdSettingValue(_ recentVideoSortedIndex: Int)
}

class RecentVideoTVC: UIViewController, BottomPopupDelegate {
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    // 전체 삭제 기능
    private var deleteStateList = [Bool]()
    @IBOutlet weak var deleteModeView: UIView!
    @IBOutlet weak var deleteAllSelectBtn: UIButton!
    @IBAction func deleteSelectedItem(_ sender: Any) {        
        var currentTrueIndex = [Int]()
        var temp = [FilterVideoData]()
        for (index, selected) in deleteStateList.enumerated() {
            if selected {
                currentTrueIndex.append(index)
            } else {
                temp.append(self.tableViewInputData[index])
            }
        }
        
        // 삭제항목 선택 카운트 체크
        if currentTrueIndex.count > 0 {
            let alert = UIAlertController(title: "삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
    
            let ok = UIAlertAction(title: "확인", style: .default) { (_) in
                self.actionDelete(currentTrueIndex, temp)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
            alert.addAction(ok)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)
        } else {
            presentAlert(message: "삭제할 항목을 선택해주세요.")
        }
    }
    private var deleteCount = 0
    private func actionDelete(_ currentTrueIndex: [Int], _ temp: [FilterVideoData]) {
        for deleteIdx in currentTrueIndex {
            if let id = self.tableViewInputData[deleteIdx].id {
            let inputData = RecentVideoInput(id: id)
                print("deleteIdx : \(inputData.id)")
                // TODO 배열로 삭제 확인
                RecentVideoTVCDataManager().postRemoveRecentVideo(param: inputData, viewController: self)
            }
        }
        deleteCount = currentTrueIndex.count
        tableViewInputData = temp
        deleteStateList.removeAll()
        for _ in tableViewInputData.indices {
            deleteStateList.append(deleteAllSelectBtn.isSelected)
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func deleteAllSelect(_ sender: Any) {
        deleteAllSelectBtn.isSelected.toggle()
        deleteStateList.removeAll()
        for _ in tableViewInputData.indices {
            deleteStateList.append(deleteAllSelectBtn.isSelected)
        }
        tableView.reloadData()
    }
    
    
    //    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var autoPlayLabel: UILabel!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        let indexPath = NSIndexPath(row: NSNotFound, section: 0)
        tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    
    var ticket: SideMenuHeaderViewModel?
    
    var inputSortNum = 4
    
    var isDeleteModeOff: Bool = true {
        didSet {
            deleteAllSelectBtn?.isSelected = false
            tableView?.reloadData()
            deleteModeView?.isHidden = isDeleteModeOff
        }
    }
    
    var pageIndex: Int!
    var recentViedo: FilterVideoModels?
    var tableViewInputData: [FilterVideoData] = []
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            tableViewInputData.removeAll()
            deleteStateList.removeAll()
//            self.tableView.reloadData()
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
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
        
        // 전체 선택 삭제 기능 추가
        deleteAllSelectBtn.setImage(UIImage(named: "checkTrue"), for: .selected)
        deleteAllSelectBtn.setTitleColor(.black, for: .normal)
        deleteAllSelectBtn.setTitleColor(.black, for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteModeOff = true
        
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
                    // 추가 항목 선택상태 설정
                    DispatchQueue.main.async {
                        for _ in json.data {
                            self.deleteStateList.append(self.deleteAllSelectBtn.isSelected)
                        }
                        
                        self.tableViewInputData.append(contentsOf: json.data)
                        self.recentViedo = json
                        if offset == 0 {
                            self.textSettings(Int(self.recentViedo?.totalNum ?? "0") ?? 0)
                        }
                        
                        self.tableView.reloadData()
                    }
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
    
    @IBAction func autoplaySwitch(_ sender: UISwitch) {
                
        if playSwitch.isOn {
            autoPlayLabel.textColor = UIColor.black
        } else {
            autoPlayLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        }
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
}

//MARK: - tableView delegate
extension RecentVideoTVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.recentViedo else { return 0 }
        
        if value.totalNum == "0" {
            return 1
        } else {
            return tableViewInputData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
            cell.deleteButton.isHidden = isDeleteModeOff
            cell.deleteView.isHidden = isDeleteModeOff
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            cell.deleteButton.isSelected = deleteStateList[indexPath.row]
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let _ = self.recentViedo else { return }
        guard let _ = self.tableViewInputData[sender.tag].id else { return }
        
        sender.isSelected.toggle()
//        let inputData = RecentVideoInput(id: id)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        deleteStateList[sender.tag] = sender.isSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if !sender.isSelected {
            deleteAllSelectBtn.isSelected = false
        }
        
//        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        tableView.reloadData()
        
        
//        RecentVideoTVCDataManager().postRemoveRecentVideo(param: inputData, viewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.recentViedo else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                vc.modalPresentationStyle = .overFullScreen
                let videoID = tableViewInputData[indexPath.row].video_id
                vc.id = videoID
                present(vc, animated: true)
            }
        }
    }
    
    //0711 - added by hp
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("cell height : \(cell.frame.height * CGFloat(indexPath.row))")
        if tableView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == self.tableViewInputData.count - 1 && !self.isLoading
            && self.tableViewInputData.count < (Int(self.recentViedo?.totalNum ?? "0") ?? 0) {
            //더보기
            print("Recent tableViewInputData : \(self.tableViewInputData.count), isLoading : \(self.isLoading)")
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
        if deleteCount != 0 {
            // 삭제 요청 시 삭제 수량만큼 카운트 감소
            let remainCnt = (Int(recentViedo?.totalNum ?? "0") ?? 0) - deleteCount
            textSettings(remainCnt)
            
            deleteCount = 0
            recentViedo?.totalNum = "\(remainCnt)"
            print("recentViedo?.totalNum : \(String(describing: recentViedo?.totalNum))")
            self.view.layoutIfNeeded()
        }
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
