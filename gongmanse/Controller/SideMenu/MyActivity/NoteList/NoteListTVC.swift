import UIKit
import BottomPopup
import Alamofire

protocol noteListTVCDelegate: AnyObject {
    func noteListPassSortedIdSettingValue(_ noteListSortedIndex: Int)
}

class NoteListTVC: UIViewController, BottomPopupDelegate {
    
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
            let alert = UIAlertController(title: "삭제", message: "선택하신 \(currentTrueIndex.count)개 항목을 삭제하시겠습니까?", preferredStyle: .alert)
    
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
        if currentTrueIndex.count > 1 {
            var ids: String = ""
            for deleteIdx in currentTrueIndex {
                if let id = self.tableViewInputData[deleteIdx].id {
                   ids.append("\(id),")
                }
            }
            
            // sql 에서 IN 명령어 사용으로 변경하여 다중항목 삭제처리는 쉼표로 구분
            let range = ids.startIndex..<ids.index(before: ids.endIndex)
            NoteListTVCDataManager().postRemoveNoteList(id: "\(ids[range])", viewController: self)
        } else {
            if let id = self.tableViewInputData[currentTrueIndex[0]].id {
                NoteListTVCDataManager().postRemoveNoteList(id: id, viewController: self)
            }
        }
        deleteCount = currentTrueIndex.count
        var remainCnt = (Int(noteList?.totalNum ?? "0") ?? 0) - self.deleteCount
        if remainCnt < 0 {
            remainCnt = 0
        }
        noteList?.totalNum = "\(remainCnt)"
        
        tableViewInputData = temp
        deleteStateList.removeAll()
        for _ in tableViewInputData.indices {
            deleteStateList.append(deleteAllSelectBtn.isSelected)
        }
        
//        self.tableView.reloadData()
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
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        let indexPath = NSIndexPath(row: NSNotFound, section: 0)
        tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    var isDeleteModeOff: Bool = true {
        didSet {
            deleteAllSelectBtn?.isSelected = false
            tableView?.reloadData()
            deleteModeView?.isHidden = isDeleteModeOff
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
            tableViewInputData.removeAll()
            deleteStateList.removeAll()
//            tableView.reloadData()
            getDataFromJson(offset: 0)
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
//        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noteListFilterNoti(_:)), name: NSNotification.Name("noteListFilterText"), object: nil)
        
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
        
    }
    
    
    @objc func noteListFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "noteListFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson(offset: Int) {
        print("Note getDataFromJson : \(offset)")
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
        
        if let url = URL(string: "\(apiBaseURL)/v/member/mynotes?token=\(Constant.token)&offset=\(offset)&limit=20&sort_id=\(inputSortNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    DispatchQueue.main.async {
                        for _ in json.data {
                            self.deleteStateList.append(self.deleteAllSelectBtn.isSelected)
                        }
                        
                        self.tableViewInputData.append(contentsOf: json.data)
                        self.noteList = json
                        self.textSettings(Int(self.noteList?.totalNum ?? "0") ?? 0)
                        
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
}

//MARK: - tableView delegate
extension NoteListTVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.noteList else { return 0 }
        
        if value.totalNum == "0" {
            return 1
        } else {
            return tableViewInputData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.noteList else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "노트 목록이 없습니다."
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTVCell") as! NoteListTVCell
            
            guard let _ = self.noteList else { return cell }
            
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
            
            cell.deleteButton.isHidden = isDeleteModeOff
            cell.deleteView.isHidden = isDeleteModeOff
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            cell.deleteButton.isSelected = deleteStateList[indexPath.row]
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let _ = self.noteList else { return }
        guard let _ = tableViewInputData[sender.tag].id else { return }
        
        sender.isSelected.toggle()
//        let inputData = NoteListInput(id: id)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        deleteStateList[sender.tag] = sender.isSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if !sender.isSelected {
            deleteAllSelectBtn.isSelected = false
        }
        
//        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        NoteListTVCDataManager().postRemoveNoteList(param: inputData, viewController: self)
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
            let _ = value.data
            
            //            guard let selectedVideoIndex = self.selectedRow else { return }
            //            print("slectedRow is \(selectedVideoIndex)")
            AutoplayDataManager.shared.isAutoPlay = false
            AutoplayDataManager.shared.videoDataList.removeAll()
            AutoplayDataManager.shared.videoSeriesDataList.removeAll()
            AutoplayDataManager.shared.currentIndex = -1
            
            let vc = VideoController()
            vc.id = tableViewInputData[sender.tag].video_id
            vc.modalPresentationStyle = .overFullScreen
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.noteList else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = self.noteList else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if value.totalNum == "0" {
//            presentAlert(message: "노트 목록이 없습니다.")
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
                vc._type = "나의 활동"
                vc._sort = sortedId ?? 4
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
    
    //0711 - added by hp
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == self.tableViewInputData.count - 1 && !self.isLoading
            && self.tableViewInputData.count < (Int(self.noteList?.totalNum ?? "0") ?? 0) {
            //더보기
            getDataFromJson(offset: self.tableViewInputData.count)
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
        if deleteCount != 0 {
            self.textSettings(Int(self.noteList?.totalNum ?? "0") ?? 0)
            //self.tableView.reloadData()
            self.view.layoutIfNeeded()
        }
        self.tableView.reloadData()
        
        if self.tableViewInputData.count == 0 {
            if self.noteList?.totalNum == "0" {
                print("empty data")
                self.isDeleteModeOff = true
            } else {
                print("get more data")
                self.deleteAllSelectBtn.isSelected.toggle()
                self.getDataFromJson(offset: 0)
            }
        }
    }
}


struct NoteListInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class NoteListTVCDataManager {
    
    func postRemoveNoteList(id: String, viewController: NoteListTVC) {
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(id)".data(using: .utf8)!, withName: "note_id")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            
        }, to: "\(apiBaseURL)/v/member/mynotes").response { (response) in
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
