import UIKit
import BottomPopup

protocol LectureQuestionsTVCDelegate: AnyObject {
    func lectureQuestionsPassSortedIdSettingValue(_ lectureQuestionsSortedIndex: Int)
}

class LectureQuestionsTVC: UITableViewController, BottomPopupDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var isDeleteMode: Bool = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var pageIndex: Int!
    var lectureQnA: FilterVideoModels?
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var delegate: LectureQuestionsTVCDelegate?
    
    var height: CGFloat = 360
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromJson()

        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(lectureQuestionsFilterNoti(_:)), name: NSNotification.Name("lectureQuestionsFilterText"), object: nil)
    }
    
    @objc func lectureQuestionsFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "lectureQuestionsFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/member/myqna?token=\(Constant.token)&offset=0&sort_id=\(sortedId ?? 4)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.lectureQnA = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.lectureQnA else { return }
        
        self.countAll.text = "총 \(value.totalNum ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        
        self.countAll.attributedText = attributedString
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "LectureQuestionsBottomPopUpVC") as! LectureQuestionsBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.lectureQnA else { return 0 }
        if value.totalNum == "0" {
            return 1
        } else {
            guard let data = self.lectureQnA?.data else { return 0}
            return data.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.lectureQnA else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "질문 목록이 없습니다."
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LectureQuestionsTVCell") as! LectureQuestionsTVCell
            
            guard let json = self.lectureQnA else { return cell }
            
            let indexData = json.data[indexPath.row]
            let defaultURL = fileBaseURL
            guard let thumbnailURL = indexData.sThumbnail else { return UITableViewCell() }
            let url = URL(string: makeStringKoreanEncoded(defaultURL + "/" + thumbnailURL))
            
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.sTitle
            cell.teachersName.text = (indexData.sTeacher ?? "nil") + " 선생님"
            cell.upLoadDate.text = indexData.dtDateCreated
            cell.subjects.text = indexData.sSubject
            cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor ?? "nil")
            
            if indexData.sUnit == "" {
                cell.term.isHidden = true
            } else if indexData.sUnit == "1" {
                cell.term.isHidden = false
                cell.term.text = "i"
            } else if indexData.sUnit == "2" {
                cell.term.isHidden = false
                cell.term.text = "ii"
            } else {
                cell.term.isHidden = false
                cell.term.text = indexData.sUnit
            }
            
            if indexData.iAnswer == "1" {
                cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
                cell.answerStatus.text = "답변 완료 >"
            } else {
                cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                cell.answerStatus.text = "대기중 >"
            }
            
            cell.deleteButton.isHidden = isDeleteMode
            cell.deleteView.isHidden = isDeleteMode
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        
        guard let json = self.lectureQnA else { return }
        guard let id = json.data[sender.tag].id else { return }
        guard let title = json.data[sender.tag].sTitle else { return }
        
        let deleteBottomPopUpVC = self.storyboard?.instantiateViewController(identifier: "LectureQuestionsDeleteBottomPopUpVC") as! LectureQuestionsDeleteBottomPopUpVC
        deleteBottomPopUpVC.height = height
        deleteBottomPopUpVC.presentDuration = presentDuration
        deleteBottomPopUpVC.dismissDuration = dismissDuration
        deleteBottomPopUpVC.video_id = id
        deleteBottomPopUpVC.video_title = title
        present(deleteBottomPopUpVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.lectureQnA else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = VideoController()
        vc.modalPresentationStyle = .fullScreen
        let videoID = lectureQnA?.data[indexPath.row].id
        vc.id = videoID
        present(vc, animated: true)
    }
}

extension LectureQuestionsTVC: LectureQuestionsBottomPopUpVCDelegate {
    func lectureQuestionsPassSortedIdRow(_ noteListSortedIdRowIndex: Int) {
        
        if noteListSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if noteListSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else if noteListSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2
        } else {                            // 4 번째 Cell
            self.sortedId = 3
        }
        
        self.delegate?.lectureQuestionsPassSortedIdSettingValue(noteListSortedIdRowIndex)
        self.tableView.reloadData()
    }
}
