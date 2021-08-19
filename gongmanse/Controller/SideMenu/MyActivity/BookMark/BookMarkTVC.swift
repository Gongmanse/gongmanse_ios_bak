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
    
    @IBOutlet weak var autoPlayLabel: UILabel!
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
    var tableViewInputData: [FilterVideoData] = []
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            self.tableViewInputData.removeAll()
            getDataFromJson()
        }
    }
    
    var delegate: BookMarkTVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookMarkFilterNoti(_:)), name: NSNotification.Name("bookMarkFilterText"), object: nil)
        
        playSwitch.addTarget(self, action: #selector(playSwitchDidTap(_:)), for: .valueChanged)
        autoPlayLabel.textColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteMode = true
        
//        playSwitch.isOn = autoPlayDataManager.isAutoplayBookMarkTab
        
    }
    
    @objc func bookMarkFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "bookMarkFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    @objc func playSwitchDidTap(_ sender: UISwitch) {
    }
    
    @IBAction func autoplaySwitch(_ sender: UISwitch) {
        
        if playSwitch.isOn {
            autoPlayLabel.textColor = UIColor.black
        } else {
            autoPlayLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        }
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
        
        if let url = URL(string: "https://api.gongmanse.com/v/member/mybookmark?token=\(Constant.token)&offset=\(tableViewInputData.count)&limit=20&sort_id=\(inputSortNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.bookMark = json
                    self.tableViewInputData.append(contentsOf: json.data)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings(Int(self.bookMark?.totalNum ?? "0") ?? 0)
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
            return tableViewInputData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let value = self.bookMark else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "즐겨찾기 목록이 없습니다."
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkTVCell") as! BookMarkTVCell
            
            guard let json = self.bookMark else { return cell }
            
            let indexData = tableViewInputData[indexPath.row]
            let defaultURL = fileBaseURL
            guard let thumbnailURL = indexData.sThumbnail else { return UITableViewCell() }
            let url = URL(string: makeStringKoreanEncoded(defaultURL + "/" + thumbnailURL))
            
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.sTitle
            cell.teachersName.text = (indexData.sTeacher ?? "nil") + " 선생님"
            cell.starRating.text = indexData.iRating?.withDouble() ?? "0.0"
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
        guard let id = tableViewInputData[sender.tag].iBookmarkId else { return }
        
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
        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        
        textSettings((Int(self.bookMark?.totalNum ?? "0") ?? 0) - 1)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.bookMark else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = self.bookMark else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if value.totalNum == "0" {
            presentAlert(message: "즐겨찾기 목록이 없습니다.")
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
            
            guard let receivedData = bookMark else { return }
            
            for dataIndex in tableViewInputData.indices {
                
                let data = tableViewInputData[dataIndex]
                
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
            autoPlayDataManager.currentViewTitleView = "즐겨찾기"
            autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
            autoPlayDataManager.videoDataList.removeAll()
            autoPlayDataManager.videoDataList.append(contentsOf: inputArr)
            autoPlayDataManager.videoSeriesDataList.removeAll()
            autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
            autoPlayDataManager.currentSort = self.sortedId ?? 0
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            if receivedData.totalNum == "0" {
                presentAlert(message: "즐겨찾기 목록이 없습니다.")
            } else {
                let vc = VideoController()
                vc.modalPresentationStyle = .fullScreen
                let videoID = tableViewInputData[indexPath.row].id
                vc.id = videoID
                present(vc, animated: true)
            }
        }
    }
    
    //0711 - added by hp
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.tableViewInputData.count - 1 {
            //더보기
            getDataFromJson()
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
