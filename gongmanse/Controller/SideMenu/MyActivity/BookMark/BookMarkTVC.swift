import UIKit
import BottomPopup

protocol BookMarkTVCDelegate: AnyObject {
    func bookMarkPassSortedIdSettingValue(_ bookMarkSortedIndex: Int)
}

struct BookMarkInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class BookMarkTVC: UITableViewController, BottomPopupDelegate {
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    
    var isDeleteMode: Bool = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var inputSortNum = 4
    
    var pageIndex: Int!
    var bookMark: FilterVideoModels?
    var tableViewInputData: [FilterVideoData]?
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var delegate: BookMarkTVCDelegate?
    
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
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookMarkFilterNoti(_:)), name: NSNotification.Name("bookMarkFilterText"), object: nil)
        
        playSwitch.addTarget(self, action: #selector(playSwitchDidTap(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteMode = true
        
        playSwitch.isOn = autoPlayDataManager.isAutoplayBookMarkTab
        
    }
    
    @objc func bookMarkFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "bookMarkFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    @objc func playSwitchDidTap(_ sender: UISwitch) {
        
        autoPlayDataManager.isAutoplayBookMarkTab = sender.isOn
        
    }
    
    
    func getDataFromJson() {
        
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
        
        if let url = URL(string: "https://api.gongmanse.com/v/member/mybookmark?token=\(Constant.token)&offset=0&limit=20&sort_id=\(inputSortNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.bookMark = json
                    self.tableViewInputData = json.data
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.bookMark else { return }
        
        self.countAll.text = "총 \(value.totalNum ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: value.totalNum ?? "nil"))
        
        self.countAll.attributedText = attributedString
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "BookMarkBottomPopUpVC") as! BookMarkBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.bookMark else { return 0 }
        
        if value.totalNum == "0" {
            return 1
        } else {
            guard let tableViewInputData = tableViewInputData else { return 0 }
            return tableViewInputData.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.bookMark else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "즐겨찾기 목록이 없습니다."
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkTVCell") as! BookMarkTVCell
            
            guard let json = self.bookMark else { return cell }
            
            let indexData = json.data[indexPath.row]
            let defaultURL = fileBaseURL
            guard let thumbnailURL = indexData.sThumbnail else { return UITableViewCell() }
            let url = URL(string: makeStringKoreanEncoded(defaultURL + "/" + thumbnailURL))
            
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.sTitle
            cell.teachersName.text = (indexData.sTeacher ?? "nil") + " 선생님"
            cell.starRating.text = indexData.iRating
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
            
            cell.deleteButton.isHidden = isDeleteMode
            cell.deleteView.isHidden = isDeleteMode
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)

            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let json = self.bookMark else { return }
        guard let id = json.data[sender.tag].iBookmarkId else { return }
        
        let baseURL = URL(string: "https://api.gongmanse.com/v/member/mybookmark")!
        let fullURL = baseURL.appendingPathComponent("/put")
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "bookmark_id": Int(id) ?? 0,
            "token": Constant.token
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("InValid response code: \(responseCode)")
                    return
                }
                
                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    print("Response JSON data = \(responseJSONData)")
                }
            }
        }.resume()
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tableViewInputData?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        getDataFromJson()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.bookMark else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var inputArr = [VideoModels]()
        
        guard let receivedData = bookMark else { return }
        
        
        for dataIndex in receivedData.data.indices {
            
            let data = receivedData.data[dataIndex]
            
            let inputData = VideoModels(seriesId: data.iSeriesId,
                                        videoId: data.id,
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
        
        let inputData = VideoInput(body: inputArr)
        autoPlayDataManager.videoDataInBookMarkVideoMyActTab = inputData
        autoPlayDataManager.currentViewTitleView = "즐겨찾기"
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if receivedData.totalNum == "0" {
            presentAlert(message: "즐겨찾기 목록이 없습니다.")
        } else {
            let vc = VideoController()
            vc.modalPresentationStyle = .fullScreen
            let videoID = bookMark?.data[indexPath.row].id
            vc.id = videoID
            present(vc, animated: true)
        }
    }
}

extension BookMarkTVC: BookMarkBottomPopUpVCDelegate {
    func bookMarkPassSortedIdRow(_ bookMarkSortedIdRowIndex: Int) {
        
        if bookMarkSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if bookMarkSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else if bookMarkSortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 2
        } else {                            // 4 번째 Cell
            self.sortedId = 3
        }
        
        self.delegate?.bookMarkPassSortedIdSettingValue(bookMarkSortedIdRowIndex)
        self.tableView.reloadData()
    }
}
