import UIKit
import BottomPopup
import Alamofire

protocol noteListTVCDelegate: AnyObject {
    func noteListPassSortedIdSettingValue(_ noteListSortedIndex: Int)
}

class NoteListTVC: UITableViewController, BottomPopupDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var isDeleteMode: Bool = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var inputSortNum = 4
    
    var pageIndex: Int!
    var noteList: FilterVideoModels?
    var tableViewInputData: [FilterVideoData] = []
    
    // didSelect로부터 받은 indexPath.row
    var selectedRow: Int?
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
//            getDataFromJson()
        }
    }
    var isLoading = false
    
    var delegate: noteListTVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        getDataFromJson()
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noteListFilterNoti(_:)), name: NSNotification.Name("noteListFilterText"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteMode = true
        
    }
    
    
    @objc func noteListFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "noteListFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
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
        
        if let url = URL(string: "https://api.gongmanse.com/v/member/mynotes?token=\(Constant.token)&offset=\(tableViewInputData.count)&limit=20&sort_id=\(inputSortNum)") {
            print("노트목록\(url.absoluteString)")
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.noteList = json
                    self.tableViewInputData.append(contentsOf: json.data)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings(Int(self.noteList?.totalNum ?? "0") ?? 0)
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
        let popupVC = self.storyboard?.instantiateViewController(identifier: "NoteListBottomPopUpVC") as! NoteListBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.noteList else { return 0 }
        
        if value.totalNum == "0" {
            return 1
        } else {
            return tableViewInputData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.noteList else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "노트 목록이 없습니다."
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTVCell") as! NoteListTVCell
            
            guard let json = self.noteList else { return cell }
            
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
            cell.indexPathRow = indexPath.row
            cell.noteVideoPlayBtn.tag = indexPath.row
            cell.noteVideoPlayBtn.addTarget(self, action: #selector(videoPlay(_:)), for: .touchUpInside)
            
            cell.deleteButton.isHidden = isDeleteMode
            cell.deleteView.isHidden = isDeleteMode
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let json = self.noteList else { return }
        guard let id = tableViewInputData[sender.tag].id else { return }
        
        let inputData = NoteListInput(id: id)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        
        NoteListTVCDataManager().postRemoveNoteList(param: inputData, viewController: self)
        
        getDataFromJson()
        tableView.reloadData()
    }
    
    @objc func videoPlay(_ sender: UIButton) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            
            presentAlert(message: "이용권을 구매해주세요")
            
        } else {
            
            //let token = Constant.token
            
            guard let value = self.noteList else { return }
            let data = value.data
            
            //            guard let selectedVideoIndex = self.selectedRow else { return }
            //            print("slectedRow is \(selectedVideoIndex)")
            AutoplayDataManager.shared.isAutoPlay = false
            AutoplayDataManager.shared.videoDataList.removeAll()
            AutoplayDataManager.shared.videoSeriesDataList.removeAll()
            AutoplayDataManager.shared.currentIndex = -1
            
            let vc = VideoController()
            vc.id = tableViewInputData[sender.tag].video_id
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
                sleep(1)
            }
            
//            // 토큰이 없는 경우
//            if token.count < 3 {
//                presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
//            } else {
//
//                guard let value = self.noteList else { return }
//                let data = value.data
//
//                //            guard let selectedVideoIndex = self.selectedRow else { return }
//                //            print("slectedRow is \(selectedVideoIndex)")
//                let vc = VideoController()
//                vc.id = data[sender.tag].video_id
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true) {
//                    sleep(1)
//                }
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.noteList else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = self.noteList else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if value.totalNum == "0" {
            presentAlert(message: "노트 목록이 없습니다.")
            return
        }
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            
            presentAlert(message: "이용권을 구매해주세요")
            
        } else {
            
            guard let value = self.noteList else { return }
            
            if value.totalNum == "0" {
                presentAlert(message: "노트목록이 없습니다.")
            } else {
                self.selectedRow = indexPath.row
                let videoID = self.tableViewInputData[indexPath.row].video_id
                let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
                
                //현재 비디오목록의 ID뿐이므로 그 이상일때 처리가 필요할듯함(페이징처리)
                var videoIDArr: [String] = []
                for i in 0 ..< (tableViewInputData.count) {
                    videoIDArr.append(tableViewInputData[i].video_id ?? "")
                }
                vc.videoIDArr = videoIDArr
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
    
    //0711 - added by hp
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.tableViewInputData.count - 1 && !self.isLoading {
            //더보기
            getDataFromJson()
        }
    }
}

extension NoteListTVC: NoteListBottomPopUpVCDelegate {
    func noteListPassSortedIdRow(_ noteListSortedIdRowIndex: Int) {
        
        if noteListSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if noteListSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else if noteListSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2
        } else {                            // 4 번째 Cell
            self.sortedId = 3
        }
        
        self.delegate?.noteListPassSortedIdSettingValue(noteListSortedIdRowIndex)
        self.tableView.reloadData()
    }
}

// MARK: - API

extension NoteListTVC {
    func didSuccessPostAPI() {
        self.textSettings((Int(self.noteList?.totalNum ?? "0") ?? 0) - 1)
        //self.tableView.reloadData()
        self.view.layoutIfNeeded()
    }
}


struct NoteListInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class NoteListTVCDataManager {
    
    func postRemoveNoteList(param: NoteListInput, viewController: NoteListTVC) {
        
        let id = param.id
        
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(id)".data(using: .utf8)!, withName: "note_id")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            
        }, to: "https://api.gongmanse.com/v/member/mynotes").response { (response) in
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
