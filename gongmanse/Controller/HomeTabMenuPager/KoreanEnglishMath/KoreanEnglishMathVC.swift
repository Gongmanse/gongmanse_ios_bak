import UIKit
import BottomPopup
import AVFoundation

protocol KoreanEnglishMathVCDelegate: AnyObject {
    func koreanPassSelectedIndexSettingValue(_ selectedIndex: Int)
    func koreanPassSortedIdSettingValue(_ sortedIndex: Int)
}

protocol subjectVideoListInfinityScroll {
    var listCount: Int { get set }
    var isMoreBool: Bool { get set }
}

class KoreanEnglishMathVC: UIViewController, BottomPopupDelegate, subjectVideoListInfinityScroll{
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    // 자동재생기능 구현을 위한 싱글톤객체를 생성한다.
    let autoPlayDataManager = AutoplayDataManager.shared
    
    var delegate: KoreanEnglishMathVCDelegate?
    
//    var problemSolvingListData: FilterVideoModels?
    
    // TODO: 추후에 "나의 설정" 완성 시, 설정값을 이 프로퍼티로 할당할 것.
    /// 설정창에서 등록한 Default 학년 / 과목으로 변경 시, API를 그에 맞게 호출하는 연산프로퍼티
    var selectedItem: Int?
    var sortedId: Int?
    
    var pageIndex: Int!
    var koreanEnglishMathVideo: VideoInput? 
    var koreanEnglishMathVideoSecond: FilterVideoModels?
    var noteShow: FilterVideoModels?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    @IBOutlet weak var autoPlayLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var ratingSequence: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var koreanEnglishMathCollection: UICollectionView!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("KoreanEnglishMathVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        koreanEnglishMathCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    var inputFilterNum = 0
    var inputSortNum = 4
    
    private let cellIdentifier = "KoreanEnglishMathAllSeriesCell"
    
    let koreanEnglishMathRC: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refresh(sender: UIRefreshControl) {
        koreanEnglishMathCollection.reloadData()
        sender.endRefreshing()
    }
    
    // 무한 스크롤 프로퍼티
    var listCount: Int = 0
    var isMoreBool: Bool = true
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        koreanEnglishMathCollection.refreshControl = koreanEnglishMathRC
        print(#function)
        getDataFromJson()
        getDataFromJsonSecond()
        textInput()
        cornerRadius()
        ChangeSwitchButton()
        
        autoPlayLabel.isHidden = true
        playSwitch.isHidden = true
        playSwitch.addTarget(self, action: #selector(playSwitchValueChanged(_:)), for: .valueChanged)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(rateFilterNoti(_:)), name: NSNotification.Name("rateFilterText"), object: nil)
        
        //xib 셀 등록
        koreanEnglishMathCollection.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        print("KoreanEnglishMathVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
        Constant.delegate = self

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let currY = self.koreanEnglishMathCollection.contentOffset.y
//            print("KoreanEnglishMathVC offsetY : \(currY)")
//            if currY == 0 {
//                self.koreanEnglishMathCollection.setContentOffset(CGPoint(x: 0, y: currY + 1), animated: false)
//            } else {
//                self.koreanEnglishMathCollection.setContentOffset(CGPoint(x: 0, y: currY - 1), animated: false)
//            }
//        }
    }
    
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = koreanEnglishMathCollection.cellForItem(at: visibleIP!) as? KoreanEnglishMathCVCell
                
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (koreanEnglishMathCollection.cellForItem(at: visibleIP!) as! KoreanEnglishMathCVCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("KoreanEnglishMathVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = koreanEnglishMathCollection.cellForItem(at: visibleIP!) as? KoreanEnglishMathCVCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    
//    @objc func videoFilterNoti(_ sender: NotificationCenter) {
//        let filterButtonTitle = UserDefaults.standard.object(forKey: "videoFilterText")
//        selectBtn.setTitle(filterButtonTitle as? String, for: .normal)
//    }
    
//    @objc func rateFilterNoti(_ sender: NotificationCenter) {
//        let rateFilterButtonTitle = UserDefaults.standard.object(forKey: "rateFilterText")
//        ratingSequence.setTitle(rateFilterButtonTitle as? String, for: .normal)
//    }
    
    /// 자동재생 설정 여부를 확인하기 위한 콜백메소드
    @objc func playSwitchValueChanged(_ sender: UISwitch) {
        
    }
    
    func textInput() {
        //label에 지정된 text 넣기
        viewTitle.text = "국영수 강의"
    }
    
    func cornerRadius() {
        //전체보기 버튼 Border corner Radius 적용
        selectBtn.layer.cornerRadius = 10
        //전체보기 버튼 border width 적용
        selectBtn.layer.borderWidth = 2
        //전체보기 버튼 border 색상 적용
        selectBtn.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        selectBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        selectBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
    }
    
    func ChangeSwitchButton() {
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        playSwitch.onTintColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
    }
        
    func getDataFromJson() {
        
        switch selectedItem {
        case 0:
            inputFilterNum = 0
        case 1:
            inputFilterNum = 2
        case 2:
            inputFilterNum = 1
        case 3:
            inputFilterNum = 3
        default:
            inputFilterNum = 0
        }
        
        
        switch sortedId {
        case 0:
            inputSortNum = 4
        case 1:
            inputSortNum = 3
        case 2:
            inputSortNum = 1
        case 3:
            inputSortNum = 2
        default:
            inputSortNum = 4
        }
        
        if inputFilterNum == 2 {
            if let url = URL(string: apiBaseURL + "/v/video/byseries?category_id=34&offset=\(listCount)&limit=20") {
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                
                if listCount == 0 {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(HomeSeriesModel.self, from: data) {
                            var videoInput = VideoInput(header: nil, body: [])
                            videoInput.header = HeaderData(resultMsg: "성공", totalRows: String(json.totalNum), isMore: "true")
                            
                            for i in 0 ..< json.data.count {
                                let item = json.data[i]
                                videoInput.body.append(VideoModels(seriesId: item.iSeriesId, videoId: "", title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: "", rating: "", isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: item.iCount))
                            }
                            self.koreanEnglishMathVideo = videoInput
                        }
                        
                        DispatchQueue.main.async {
                            self.koreanEnglishMathCollection.reloadData()
                            self.textSettings()
                        }
                        
                    }.resume()
                } else {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(HomeSeriesModel.self, from: data) {
                            //                        guard let isMores = json.header?.isMore else { return}
                            //                        self.isMoreBool = Bool(isMores) ?? false
                            for i in 0..<json.data.count {
                                let item = json.data[i]
                                self.koreanEnglishMathVideo?.body.append(VideoModels(seriesId: item.iSeriesId, videoId: "", title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: "", rating: "", isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: item.iCount))
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.koreanEnglishMathCollection.reloadData()
                        }
                        
                    }.resume()
                }
            }
        } else if inputFilterNum == 3 { //노트보기
            getDataFromJsonNote()
        } else if let url = URL(string: KoreanEnglishMath_Video_URL + "offset=\(listCount)&limit=20&sortId=\(inputFilterNum == 1 ? 2 : inputSortNum)&type=\(inputFilterNum)") {
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        //print(json.body)
                        self.koreanEnglishMathVideo = json
                    }
                    
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        //                        guard let isMores = json.header?.isMore else { return}
                        //                        self.isMoreBool = Bool(isMores) ?? false
                        for i in 0..<json.body.count {
                            self.koreanEnglishMathVideo?.body.append(json.body[i])
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                    }
                    
                }.resume()
            }
            
        }
    }
    
    func getDataFromJsonSecond() {
        if let url = URL(string: "\(apiBaseURL)/v/video/bycategory?category_id=34&offset=\(listCount)&commentary=\(inputFilterNum)&sort_id=\(inputFilterNum == 1 ? 2 : inputSortNum)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        //print(json.body)
                        self.koreanEnglishMathVideoSecond = json
                        
                        // 문제풀이인 경우,
                        //                        if self.selectedItem == 2 {
                        //                            self.problemSolvingListData = json
                        //                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        //                        guard let isMores = json.isMore else { return}
                        //                        self.isMoreBool = Bool(isMores)
                        for i in 0..<json.data.count {
                            self.koreanEnglishMathVideoSecond?.data.append(json.data[i])
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                    }
                    
                }.resume()
            }
        }
    }
    
    func getDataFromJsonNote() {
        if let url = URL(string: apiBaseURL + "/v/video/notelist?category_id=34&offset=\(listCount)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    
                    if let json = try? decoder.decode(HomeNoteModel.self, from: data) {
                        var videoInput = VideoInput(header: nil, body: [])
                        videoInput.header = HeaderData(resultMsg: "성공", totalRows: String(json.totalNum), isMore: "true")
                        
                        for i in 0 ..< json.data.count {
                            let item = json.data[i]
                            videoInput.body.append(VideoModels(seriesId: item.iSeriesId, videoId: item.videoID, title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: item.sUnit, rating: item.iRating, isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: ""))
                        }
                        self.koreanEnglishMathVideo = videoInput
                    }
                    
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    
                    if let json = try? decoder.decode(HomeNoteModel.self, from: data) {
                        //                        guard let isMores = json.header?.isMore else { return}
                        //                        self.isMoreBool = Bool(isMores) ?? false
                        for i in 0..<json.data.count {
                            let item = json.data[i]
                            self.koreanEnglishMathVideo?.body.append(VideoModels(seriesId: item.iSeriesId, videoId: item.videoID, title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: item.sUnit, rating: item.iRating, isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: ""))
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.koreanEnglishMathCollection.reloadData()
                    }
                    
                }.resume()
            }
        }
    }
    
    func textSettings() {
        guard let value = self.koreanEnglishMathVideo?.header else { return }
        
        let strCount = value.totalRows?.withCommas() ?? "0"
        self.videoTotalCount.text = "총 \(strCount)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoTotalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: strCount))
        
        self.videoTotalCount.attributedText = attributedString
    }
    
    @IBAction func selectMenuBtn(_ sender: UIButton) {
        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "KoreanEnglishMathBottomPopUpVC") as! KoreanEnglishMathBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.selectItem = self.selectedItem
        present(popupVC, animated: true)
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "KoreanEnglishMathAlignmentVC") as! KoreanEnglishMathAlignmentVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }
    
    @IBAction func playSwitchAction(_ sender: Any) {
        if playSwitch.isOn {
            autoPlayLabel.textColor = UIColor.black
        } else {
            autoPlayLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        }
    }
}

extension KoreanEnglishMathVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.koreanEnglishMathVideo?.body else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanEnglishMathCVCell", for: indexPath) as! KoreanEnglishMathCVCell
        guard let json = self.koreanEnglishMathVideo else { return cell }
        let indexData = json.body[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(indexData.thumbnail ?? "nil"))
        
        /// cell UI업데이트를 위한 메소드
        func setUpDefaultCellSetting() {
            cell.delegate = self
            cell.videoID = indexData.videoId
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.title
            cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
            cell.subjects.text = indexData.subject
            cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
            cell.starRating.text = indexData.rating?.withDouble() ?? "0.0"
            cell.videoPlayButton.addTarget(self, action: #selector(videoPlay(_:)), for: .touchUpInside)
            cell.videoPlayButton.isHidden = true
            cell.videoPlayButton.tag = indexPath.row
        }
        
        /// cell keyword 업데이트를 위한 메소드
        func addKeywordToCell() {
            cell.term.isHidden = true
            if let unit = indexData.unit, !unit.isEmpty {
                cell.term.isHidden = false
                if unit == "1" {
                    cell.term.text = "i"
                } else if unit == "2" {
                    cell.term.text = "ii"
                } else {
                    cell.term.text = unit
                }
            }
        }
        
        if selectedItem == 0 {
            // 전체 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            ratingSequence.isHidden = false
            filterImage.isHidden = false
            return cell
            
        } else if selectedItem == 1 {
            // 시리즈보기
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanEnglishMathAllSeriesCell", for: indexPath) as! KoreanEnglishMathAllSeriesCell
            guard let json = self.koreanEnglishMathVideo else { return cell }
            let indexData = json.body[indexPath.row]
            let url = URL(string: makeStringKoreanEncoded(indexData.thumbnail ?? "nil"))
            
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.title
            cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
            cell.subjects.text = indexData.subject
            cell.seriesVideoCount.text = indexData.totalRows
            cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
            
            cell.videoThumbnail.layer.cornerRadius = 13
            cell.videoThumbnail.layer.masksToBounds = true
            
            playSwitch.isHidden = true
            autoPlayLabel.isHidden = true
            ratingSequence.isHidden = true
            filterImage.isHidden = true
            return cell
            
        } else if selectedItem == 2 {
            // 문제풀이
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            ratingSequence.isHidden = true
            filterImage.isHidden = true
            return cell
            
        } else if selectedItem == 3 {
            // 노트 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = true
            autoPlayLabel.isHidden = true
            ratingSequence.isHidden = true
            filterImage.isHidden = true
            cell.videoPlayButton.isHidden = false
            return cell
            
        } else {
            // 전체 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            ratingSequence.isHidden = false
            filterImage.isHidden = false
            return cell
        }
    }
    
    @objc func videoPlay(_ sender: UIButton) {
        
        let token = Constant.token
        
        // 토큰이 없는 경우
        if token.count < 3 {
            
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            
        } else {
            // 이용권 사용기간 체크 추가
            guard Constant.remainPremiumDateInt != nil else {
                presentAlert(message: "이용권을 구매해주세요")
                return
            }
            
            guard let value = self.koreanEnglishMathVideo else { return }
            let data = value.body
            
            //            guard let selectedVideoIndex = self.selectedRow else { return }
            //            print("slectedRow is \(selectedVideoIndex)")
            AutoplayDataManager.shared.isAutoPlay = false
            AutoplayDataManager.shared.currentIndex = -1
            AutoplayDataManager.shared.videoDataList.removeAll()
            AutoplayDataManager.shared.videoSeriesDataList.removeAll()
            
            let vc = VideoController()
            vc.id = data[sender.tag].videoId
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true) {
                sleep(1)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isGuest {
            print("isGuest")
            return
        }
        if self.selectedItem == 3 {
            print("isNoteList")
            return
        }
        
        let indexPaths = koreanEnglishMathCollection.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = koreanEnglishMathCollection.cellForItem(at: ip) as? KoreanEnglishMathCVCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("KoreanEnglishMathVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
            if isAutoScroll {
                // auto scroll 시 재생되지 않도록 적용
                isAutoScroll = false
            } else {
                startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
            }
            
//                let delay = isAutoScroll ? 0.3 : 0.0
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    // auto scroll 시 화면 그려진 이후에 재생되도록 딜레이 설정
//                    self.startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
//                    self.isAutoScroll = false
//                }
            return
        }

        // 마지막 아이템까지 스크롤된 경우 마지막 아이템 재생
        // - 이전 재생 videoCell 이 65% 이상 가려지기 전에 다음 항목 재생되도록 별도 처리
        let heightSV = scrollView.frame.size.height
        let offSetY = scrollView.contentOffset.y
        let distanceFromBot = scrollView.contentSize.height - offSetY
        if distanceFromBot <= heightSV {// distanceFromBot == heightSV 인 순간 바닥점 터치.
            print("KoreanEnglishMathVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = koreanEnglishMathCollection.cellForItem(at: visibleIP!) as? KoreanEnglishMathCVCell
                print("KoreanEnglishMathVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (koreanEnglishMathCollection.cellForItem(at: visibleIP!) as! KoreanEnglishMathCVCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("KoreanEnglishMathVC play first item")
                let videoCell = cells[0] as! KoreanEnglishMathCVCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = koreanEnglishMathCollection.cellForItem(at: visibleIP!) as? KoreanEnglishMathCVCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(koreanEnglishMathCollection.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("KoreanEnglishMathVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    print("KoreanEnglishMathVC visibleIP!.row : \(visibleIP!.row)")
                    // 현재 화면에 보여지고있는 셀들 중에서 다음 재생할 파일 선택.
                    // 빠르게 스크롤 시 재생중이던 셀과 다음 재생하려고 하는 셀이 화면에 안보이는 상태일 수 있어 내용 수정.
                    var indexPath = IndexPath(row: indexPaths[1].row, section: 0)// 중간 데이터로 초기화
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        print("KoreanEnglishMathVC move up")
                        for ip in indexPaths {
//                            print("KoreanEnglishMathVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 위 셀을 선택
                                var row = visibleIP!.row - 1
                                if row < 0 { row = 0 }
                                indexPath.row = row
                            }
                        }

                    }
                    else if (self.lastContentOffset < scrollView.contentOffset.y) {
                        print("KoreanEnglishMathVC move down")
                        for ip in indexPaths {
//                            print("KoreanEnglishMathVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 아래 셀을 선택
                                var row = visibleIP!.row + 1
                                if row == self.koreanEnglishMathVideo!.body.count { row = self.koreanEnglishMathVideo!.body.count - 1 }
                                indexPath.row = row
                            }
                        }
                    } else {
                        print("???")
                    }
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    visibleIP = indexPath
                    let afterVideoCell = (koreanEnglishMathCollection.cellForItem(at: visibleIP!) as! KoreanEnglishMathCVCell)
                    afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? KoreanEnglishMathCVCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 자동 재생 중지
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
            
        } else {
            
            // 시리즈보기: self.selectedItem == 1
            // 문제풀이: self.selectedItem == 2
            // 전체보기
            if self.selectedItem == 0 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                if let videoID = koreanEnglishMathVideo?.body[indexPath.row].videoId {
                    videoDataManager.isFirstPlayVideo = true
                    vc.id = videoID
                    if let seekTime = seekTimes[videoID] {
                        print("set seekTime \(seekTime.seconds)")
                        vc.autoPlaySeekTime = seekTime
                        vc.isStartVideo = true
        //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
                    }
                    
                    vc.modalPresentationStyle = .overFullScreen
                    
                    autoPlayDataManager.currentViewTitleView = "국영수"
                    autoPlayDataManager.currentFiltering = "전체보기"
                    autoPlayDataManager.currentSort = self.sortedId ?? 0
                    autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
                    autoPlayDataManager.videoDataList.removeAll()
                    autoPlayDataManager.videoDataList.append(contentsOf: koreanEnglishMathVideo!.body)
                    autoPlayDataManager.videoSeriesDataList.removeAll()
                    autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
                    
                    present(vc, animated: true)
                
                }
                // 시리즈 보기
            } else if self.selectedItem == 1 {
                let vc = self.storyboard?.instantiateViewController(identifier: "SeriesVC") as! SeriesVC
                let seriesID = koreanEnglishMathVideo?.body[indexPath.row].seriesId
                vc.receiveSeriesId = seriesID
                vc.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(vc, animated: true)
                print("DEBUG: 1번")
                
                // 문제 풀이
            } else if self.selectedItem == 2 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                if let videoID = koreanEnglishMathVideo?.body[indexPath.row].videoId {
                    videoDataManager.isFirstPlayVideo = true
                    vc.id = videoID
                    if let seekTime = seekTimes[videoID] {
                        print("set seekTime \(seekTime.seconds)")
                        vc.autoPlaySeekTime = seekTime
                        vc.isStartVideo = true
                    }
    //                let seriesID = koreanEnglishMathVideoSecond?.data[indexPath.row].iSeriesId
    //                vc.koreanSeriesId = seriesID
    //                vc.koreanSwitchValue = playSwitch
    //                vc.koreanReceiveData = koreanEnglishMathVideo
    //                vc.koreanSelectedBtn = selectBtn
    //                //                vc.koreanViewTitle = viewTitle.text
    //                vc.koreanViewTitle = "국영수"
                    //                autoplayDataManager.currentViewTitleView = "국영수 강의"
                    
                    vc.modalPresentationStyle = .overFullScreen
                    
                    autoPlayDataManager.currentViewTitleView = "국영수"
                    autoPlayDataManager.currentFiltering = "문제풀이"
                    autoPlayDataManager.currentSort = 2
                    autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
                    autoPlayDataManager.videoDataList.removeAll()
                    autoPlayDataManager.videoDataList.append(contentsOf: koreanEnglishMathVideo!.body)
                    autoPlayDataManager.videoSeriesDataList.removeAll()
                    autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
                    
                    present(vc, animated: true)
                    print("DEBUG: 2번")
                }
                // 노트보기
            } else if self.selectedItem == 3 {
                
                let videoID = koreanEnglishMathVideo?.body[indexPath.row].videoId
                let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
                
                // 노트 전체보기 화면에 SeriesID가 필요없음
                //                if let seriesID = noteShow?.data[indexPath.row].iSeriesId {
                //                    vc.seriesID = seriesID
                //                }
                //현재 비디오목록의 ID뿐이므로 그 이상일때 처리가 필요할듯함(페이징처리)
                var videoIDArr: [String] = []
                for i in 0 ..< (koreanEnglishMathVideo?.body.count)! {
                    videoIDArr.append(koreanEnglishMathVideo?.body[i].videoId ?? "")
                }
                vc.videoIDArr = videoIDArr
                vc._type = "국영수"
                vc._sort = sortedId ?? 4
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                print("DEBUG: 3번")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = koreanEnglishMathVideo?.body.count  else { return }
        
        guard let _ = koreanEnglishMathVideoSecond?.data.count else { return }
        
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == cellCount - 1 {
            
            listCount += 20
            getDataFromJson()
            
        }/* else if indexPath.row == cellCountSecond - 1 {
            
            listCount += 20
            getDataFromJsonSecond()
        }*/
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        
        //0707 - edited by hp
        return CGSize(width: width, height: ((width - 20) / 16 * 9 + 70))
    }
}


//extension KoreanEnglishMathVC: KoreanEnglishMathTitleCVCellDelegate {
//    func presentBottomPopUp() {
//        self.present(KoreanEnglishMathBottomPopUpVC(), animated: true)
//    }
//}

// MARK: - KoreanEnglishMathBottomPopUpVCDelegate
/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension KoreanEnglishMathVC: KoreanEnglishMathBottomPopUpVCDelegate, KoreanEnglishMathAlignmentVCDelegate {
    
    func passSortedIdRow(_ sortedIdRowIndex: Int, _ rateFilterText: String) {
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        ratingSequence.setTitle(rateFilterText, for: .normal)
        
        if sortedIdRowIndex == 2 { //이름순
            self.sortedId = 2
        } else if sortedIdRowIndex == 3 { //과목순
            self.sortedId = 3
        } else if sortedIdRowIndex == 0 { //최신순
            self.sortedId = 0
        } else { //평점순
            self.sortedId = 1
        }
        
        self.delegate?.koreanPassSortedIdSettingValue(sortedIdRowIndex)
        
        self.koreanEnglishMathVideo?.body.removeAll()
        self.koreanEnglishMathCollection.reloadData()
        listCount = 0
        lastContentOffset = 0
        getDataFromJson()
    }
    
    func passSelectedRow(_ selectedRowIndex: Int, _ videoFilterText: String) {
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        selectBtn.setTitle(videoFilterText, for: .normal)
        
        if selectedRowIndex == 0 {
            self.selectedItem = 0 // 전체 보기
        } else if selectedRowIndex == 2 {
            self.selectedItem = 2 // 시리즈 보기
        } else if selectedRowIndex == 1 {
            self.selectedItem = 1 // 문제 풀이
        } else {
            self.selectedItem = 3 // 노트 보기
        }
        // 클릭한 indexRow에 맞는 index를 "KoreanEnglishMathVC"의 프로퍼티에 전달한다.
        //        self.selectedItem = selectedRowIndex
        self.delegate?.koreanPassSelectedIndexSettingValue(selectedRowIndex)
        // 변경된 selectedItem으로 다시 API를 호출한다.
        //        getDataFromJson()
        // collectionview를 업데이트한다.
        self.koreanEnglishMathVideo?.body.removeAll()
        self.koreanEnglishMathCollection.reloadData()
        listCount = 0
        lastContentOffset = 0
        getDataFromJson()
    }
}


extension KoreanEnglishMathVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = koreanEnglishMathCollection.cellForItem(at: visibleIP!) as? KoreanEnglishMathCVCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.koreanEnglishMathVideo!.body.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            koreanEnglishMathCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}

extension KoreanEnglishMathVC: LoginStatusChecker {
    func logout() {
        isGuest = true
        print("KoreanEnglishMathVC logout... current visibleIP : \(String(describing: visibleIP))")
        if let _ = visibleIP {
            stopCurrentVideoCell()
        }
    }
}
