import UIKit
import BottomPopup

protocol noteListTVCDelegate: AnyObject {
    func noteListPassSortedIdSettingValue(_ noteListSortedIndex: Int)
}

class NoteListTVC: UITableViewController, BottomPopupDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var pageIndex: Int!
    var noteList = FilterVideoModels(isMore: true, totalNum: "", data: [FilterVideoData]())
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
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
    
    @objc func noteListFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "noteListFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/member/mynotes?token=\(Constant.token)&offset=0&limit=20&sort_id=\(sortedId ?? 4)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.noteList = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        
        //guard let value = self.noteList else { return }
        let value = self.noteList
        
        self.countAll.text = "총 \(value.totalNum ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        
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
        //guard let value = self.noteList else { return 0 }
        let value = self.noteList
        if value.totalNum == "0" {
            return 1
        } else {
            //guard let data = self.noteList?.data else { return 0}
            let data = self.noteList.data
            return data.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //guard let value = self.noteList else { return UITableViewCell() }
        
        let value = self.noteList
        
        if value.totalNum == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "질문 목록이 없습니다."
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTVCell") as! NoteListTVCell
            
            //guard let json = self.noteList else { return cell }
            let json = self.noteList
            
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
            //cell.noteVideoPlayBtn.addTarget(self, action: #selector(videoPlay), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func videoPlay() {
        
        let token = Constant.token
        
        // 토큰이 없는 경우
        if token.count < 3 {
            
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            
        } else {
            
            //guard let value = self.noteList else { return }
            let value = self.noteList.data
            
            let vc = VideoController()
            vc.modalPresentationStyle = .fullScreen
    }
}
    
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //guard let value = self.noteList else { return 0 }
        let value = self.noteList
        
        if value.totalNum == "0" {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoID = noteList.data[indexPath.row].video_id
        let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
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
