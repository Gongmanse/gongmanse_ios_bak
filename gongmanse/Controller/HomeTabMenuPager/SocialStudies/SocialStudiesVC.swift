import UIKit
import BottomPopup
import AVFoundation

protocol SocialStudiesVCDelegate: AnyObject {
    func socialStudiesPassSelectedIndexSettingValue(_ selectedIndex: Int)
    func socialStudiesPassSortedIdSettingValue(_ sortedIndex: Int)
}

class SocialStudiesVC: UIViewController, BottomPopupDelegate, subjectVideoListInfinityScroll {
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    var delegate: SocialStudiesVCDelegate?
    let autoPlayDataManager = AutoplayDataManager.shared
    
    // TODO: 추후에 "나의 설정" 완성 시, 설정값을 이 프로퍼티로 할당할 것.
    /// 설정창에서 등록한 Default 학년 / 과목으로 변경 시, API를 그에 맞게 호출하는 연산프로퍼티
    var selectedItem: Int?
    var sortedId: Int?
    
    var pageIndex: Int!
    var socialStudiesVideo: VideoInput?
    var socialStudiesVideoSecond: FilterVideoModels?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    @IBOutlet weak var autoPlayLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var socialStudiesCollection: UICollectionView!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("SocialStudiesVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        socialStudiesCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    var inputFilterNum = 0
    var inputSortNum = 4
    var noteShow: FilterVideoModels?
    
    private let cellIdentifier = "KoreanEnglishMathAllSeriesCell"
    
    //collectionView 새로고침
    let socialStudiesRC: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    
    // 무한스크롤
    var listCount: Int = 0
    
    var isMoreBool: Bool = true
    //
    
    //collectionView 새로고침 objc
    @objc private func refresh(sender: UIRefreshControl) {
        socialStudiesCollection.reloadData()
        sender.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialStudiesCollection.refreshControl = socialStudiesRC
        
        getDataFromJson()
        getDataFromJsonSecond()
        textInput()
        cornerRadius()
        ChangeSwitchButton()
        
        autoPlayLabel.isHidden = true
        playSwitch.isHidden = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(rateFilterNoti(_:)), name: NSNotification.Name("rateFilterText"), object: nil)
        
        playSwitch.addTarget(self, action: #selector(autoPlayValueChanged(_:)), for: .valueChanged)
        
        //xib 셀 등록
        socialStudiesCollection.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        print("SocialStudiesVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
        Constant.delegate = self
    }
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = socialStudiesCollection.cellForItem(at: visibleIP!) as? SocialStudiesCVCell
                
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (socialStudiesCollection.cellForItem(at: visibleIP!) as! SocialStudiesCVCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("SocialStudiesVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = socialStudiesCollection.cellForItem(at: visibleIP!) as? SocialStudiesCVCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    // MARK: - Action
    
    @objc func autoPlayValueChanged(_ sender: UISwitch) {
        
    }
    
//    @objc func videoFilterNoti(_ sender: NotificationCenter) {
//        let filterButtonTitle = UserDefaults.standard.object(forKey: "videoFilterText")
//        selectBtn.setTitle(filterButtonTitle as? String, for: .normal)
//    }
    
//    @objc func rateFilterNoti(_ sender: NotificationCenter) {
//        let rateFilterButtonTitle = UserDefaults.standard.object(forKey: "rateFilterText")
//        filteringBtn.setTitle(rateFilterButtonTitle as? String, for: .normal)
//    }
    
    func textInput() {
        //label에 지정된 text 넣기
        viewTitle.text = "사회 강의"
    }
    
    func cornerRadius() {
        //전체보기 버튼 Border 와 Corner Radius 적용
        selectBtn.layer.cornerRadius = 9
        //전체보기 버튼 Border width 적용
        selectBtn.layer.borderWidth = 2
        //전체보기 버튼 Border 색상 적용
        selectBtn.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        
        selectBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        selectBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
    }
    
    func ChangeSwitchButton() {
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
    }
    
    //api
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
            if let url = URL(string: apiBaseURL + "/v/video/byseries?category_id=35&offset=\(listCount)&limit=20") {
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
                            self.socialStudiesVideo = videoInput
                        }
                        
                        DispatchQueue.main.async {
                            self.socialStudiesCollection.reloadData()
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
                                self.socialStudiesVideo?.body.append(VideoModels(seriesId: item.iSeriesId, videoId: "", title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: "", rating: "", isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: item.iCount))
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.socialStudiesCollection.reloadData()
                        }
                        
                    }.resume()
                }
            }
        } else if inputFilterNum == 3 { //노트보기
            getDataFromJsonNote()
        } else if let url = URL(string: SocialStudies_Video_URL + "offset=\(listCount)&limit=20&sortId=\(inputFilterNum == 1 ? 2 : inputSortNum)&type=\(inputFilterNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        //print(json.data)
                        self.socialStudiesVideo = json
                    }
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        
                        for i in 0..<json.body.count {
                            self.socialStudiesVideo?.body.append(json.body[i])
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            }
        }
    }
    
    func getDataFromJsonSecond() {
        if let url = URL(string: "\(apiBaseURL)/v/video/bycategory?category_id=35&offset=\(listCount)&commentary=\(inputFilterNum)&sort_id=\(inputFilterNum == 1 ? 2 : inputSortNum)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        //print(json.body)
                        self.socialStudiesVideoSecond = json
                    }
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        
                        for i in 0..<json.data.count {
                            self.socialStudiesVideoSecond?.data.append(json.data[i])
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            }
        }
    }
    
    func getDataFromJsonNote() {
        if let url = URL(string: apiBaseURL + "/v/video/notelist?category_id=35&offset=\(listCount)&limit=20") {
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
                        self.socialStudiesVideo = videoInput
                    }
                    
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
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
                            self.socialStudiesVideo?.body.append(VideoModels(seriesId: item.iSeriesId, videoId: item.videoID, title: item.sTitle, tags: "", teacherName: item.sTeacher, thumbnail: "\(fileBaseURL)/\(item.sThumbnail!)", subject: item.sSubject, subjectColor: item.sSubjectColor, unit: item.sUnit, rating: item.iRating, isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: ""))
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.socialStudiesCollection.reloadData()
                    }
                    
                }.resume()
            }
        }
    }
    
    func textSettings() {
        guard let value = self.socialStudiesVideo?.header else { return }
        
        let strCount = value.totalRows?.withCommas() ?? "0"
        self.videoTotalCount.text = "총 \(strCount)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoTotalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: strCount))
        
        self.videoTotalCount.attributedText = attributedString
    }
    
    @IBAction func selectMenuBtn(_ sender: Any) {
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

extension SocialStudiesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.socialStudiesVideo?.body else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialStudiesCVCell", for: indexPath) as! SocialStudiesCVCell
        guard let json = self.socialStudiesVideo else { return cell }
        
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
            filteringBtn.isHidden = false
            filterImage.isHidden = false
            return cell
            
        } else if selectedItem == 1 {
            // 시리즈 보기
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanEnglishMathAllSeriesCell", for: indexPath) as! KoreanEnglishMathAllSeriesCell
            guard let json = self.socialStudiesVideo else { return cell }
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
            filteringBtn.isHidden = true
            filterImage.isHidden = true
            return cell
            
        } else if selectedItem == 2 {
            // 문제 풀이
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            filteringBtn.isHidden = true
            filterImage.isHidden = true
            return cell
            
        } else if selectedItem == 3 {
            // 노트 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = true
            autoPlayLabel.isHidden = true
            filteringBtn.isHidden = true
            filterImage.isHidden = true
            cell.videoPlayButton.isHidden = false
            return cell
            
        } else {
            // 전체 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            filteringBtn.isHidden = false
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
            
            guard let value = self.socialStudiesVideo else { return }
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
        
        let indexPaths = socialStudiesCollection.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = socialStudiesCollection.cellForItem(at: ip) as? SocialStudiesCVCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("SocialStudiesVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
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
            print("SocialStudiesVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = socialStudiesCollection.cellForItem(at: visibleIP!) as? SocialStudiesCVCell
                print("SocialStudiesVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (socialStudiesCollection.cellForItem(at: visibleIP!) as! SocialStudiesCVCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("SocialStudiesVC play first item")
                let videoCell = cells[0] as! SocialStudiesCVCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = socialStudiesCollection.cellForItem(at: visibleIP!) as? SocialStudiesCVCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(socialStudiesCollection.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("SocialStudiesVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    var afterVideoCell: SocialStudiesCVCell? = nil
                    if visibleIP!.row == indexPaths[0].row {
                        print("SocialStudiesVC scroll to down")
                        visibleIP = indexPaths[1]
                        afterVideoCell = (socialStudiesCollection.cellForItem(at: visibleIP!) as! SocialStudiesCVCell)
                    } else if visibleIP!.row == indexPaths[cellCount - 1].row {
                        print("SocialStudiesVC scroll to up")
                        visibleIP = indexPaths[cellCount - 2]
                        afterVideoCell = (socialStudiesCollection.cellForItem(at: visibleIP!) as! SocialStudiesCVCell)
                    } else {
                        print("SocialStudiesVC visibleIP : \(visibleIP!.row)")
                        return
                    }
                    afterVideoCell!.startPlayback(seekTimes[afterVideoCell!.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? SocialStudiesCVCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
}

extension SocialStudiesVC: UICollectionViewDelegate {
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
            if self.selectedItem == 0 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                if let videoID = socialStudiesVideo?.body[indexPath.row].videoId {
                    videoDataManager.isFirstPlayVideo = true
                    vc.id = videoID
                    if let seekTime = seekTimes[videoID] {
                        print("set seekTime \(seekTime.seconds)")
                        vc.autoPlaySeekTime = seekTime
                        vc.isStartVideo = true
        //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
                    }
                    
                    vc.modalPresentationStyle = .overFullScreen
                    
                    autoPlayDataManager.currentViewTitleView = "사회"
                    autoPlayDataManager.currentFiltering = "전체보기"
                    autoPlayDataManager.currentSort = self.sortedId ?? 0
                    autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
                    autoPlayDataManager.videoDataList.removeAll()
                    autoPlayDataManager.videoDataList.append(contentsOf: socialStudiesVideo!.body)
                    autoPlayDataManager.videoSeriesDataList.removeAll()
                    autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
                    
                    present(vc, animated: true)
                }
            } else if self.selectedItem == 1 {
                let vc = self.storyboard?.instantiateViewController(identifier: "SeriesVC") as! SeriesVC
                let seriesID = socialStudiesVideo?.body[indexPath.row].seriesId
                vc.receiveSeriesId = seriesID
                vc.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(vc, animated: true)
                print("DEBUG: 1번")
            } else if self.selectedItem == 2 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                if let videoID = socialStudiesVideo?.body[indexPath.row].videoId {
                    videoDataManager.isFirstPlayVideo = true
                    vc.id = videoID
                    if let seekTime = seekTimes[videoID] {
                        print("set seekTime \(seekTime.seconds)")
                        vc.autoPlaySeekTime = seekTime
                        vc.isStartVideo = true
                    }
    //                let seriesID = socialStudiesVideoSecond?.data[indexPath.row].iSeriesId
    //                vc.socialStudiesSeriesId = seriesID
    //                vc.socialStudiesSwitchValue = playSwitch
    //                vc.socialStudiesReceiveData = socialStudiesVideo
    //                vc.socialStudiesSelectedBtn = selectBtn
    //                //                vc.koreanViewTitle = viewTitle.text
    //                vc.socialStudiesViewTitle = "사회"
                    //                autoplayDataManager.currentViewTitleView = "국영수 강의"
                    
                    vc.modalPresentationStyle = .overFullScreen
                    
                    autoPlayDataManager.currentViewTitleView = "사회"
                    autoPlayDataManager.currentFiltering = "문제풀이"
                    autoPlayDataManager.currentSort = 2
                    autoPlayDataManager.isAutoPlay = self.playSwitch.isOn
                    autoPlayDataManager.videoDataList.removeAll()
                    autoPlayDataManager.videoDataList.append(contentsOf: socialStudiesVideo!.body)
                    autoPlayDataManager.videoSeriesDataList.removeAll()
                    autoPlayDataManager.currentIndex = self.playSwitch.isOn ? indexPath.row : -1
                    
                    present(vc, animated: true)
                    print("DEBUG: 2번")
                }
            } else if self.selectedItem == 3 {
                let videoID = socialStudiesVideo?.body[indexPath.row].videoId
                let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
                
                //0711 - edited by hp
                // 노트 전체보기 화면에 SeriesID가 필요없음
//                if let seriesID = noteShow?.data[indexPath.row].iSeriesId {
//                    vc.seriesID = seriesID
//                }
                //현재 비디오목록의 ID뿐이므로 그 이상일때 처리가 필요할듯함(페이징처리)
                var videoIDArr: [String] = []
                for i in 0 ..< (socialStudiesVideo?.body.count)! {
                    videoIDArr.append(socialStudiesVideo?.body[i].videoId ?? "")
                }
                vc.videoIDArr = videoIDArr
                vc._type = "사회"
                vc._sort = sortedId ?? 4
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                print("DEBUG: 3번")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = socialStudiesVideo?.body.count else { return }
        
        guard let _ = socialStudiesVideoSecond?.data.count else { return }
        
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == cellCount - 1 {
            listCount += 20
            getDataFromJson()
            
            //            let moveIndex = ((socialStudiesVideoSecond?.data.count)! - 20)
            //            self.socialStudiesCollection.scrollToItem(at: IndexPath(item: moveIndex, section: 0),
            //                                                      at: .top, animated: false)
            
        }/* else if indexPath.row == cellCountSecond - 1 {
            listCount += 20
            getDataFromJsonSecond()
        }*/
    }
}

extension SocialStudiesVC: UICollectionViewDelegateFlowLayout {
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

// MARK: - KoreanEnglishMathBottomPopUpVCDelegate
/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension SocialStudiesVC: KoreanEnglishMathBottomPopUpVCDelegate, KoreanEnglishMathAlignmentVCDelegate {
    
    func passSortedIdRow(_ sortedIdRowIndex: Int, _ rateFilterText: String) {
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        filteringBtn.setTitle(rateFilterText, for: .normal)
        
        if sortedIdRowIndex == 2 {          // 1 번째 Cell
            self.sortedId = 2 // 평점순
        } else if sortedIdRowIndex == 3 {   // 2 번째 Cell
            self.sortedId = 3 // 최신순
        } else if sortedIdRowIndex == 0 {   // 3 번째 Cell
            self.sortedId = 0 // 이름순
        } else {                            // 4 번째 Cell
            self.sortedId = 1 // 과목순
        }
        
        self.delegate?.socialStudiesPassSortedIdSettingValue(sortedIdRowIndex)
        self.socialStudiesVideo?.body.removeAll()
        self.socialStudiesCollection.reloadData()
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
        } else if selectedRowIndex == 3 {
            self.selectedItem = 3 // 노트 보기
        }
        // 클릭한 indexRow에 맞는 index를 "KoreanEnglishMathVC"의 프로퍼티에 전달한다.
        //        self.selectedItem = selectedRowIndex
        self.delegate?.socialStudiesPassSelectedIndexSettingValue(selectedRowIndex)
        // 변경된 selectedItem으로 다시 API를 호출한다.
        //        getDataFromJson()
        // collectionview를 업데이트한다.
        self.socialStudiesVideo?.body.removeAll()
        self.socialStudiesCollection.reloadData()
        listCount = 0
        lastContentOffset = 0
        getDataFromJson()
    }
}


extension SocialStudiesVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = socialStudiesCollection.cellForItem(at: visibleIP!) as? SocialStudiesCVCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.socialStudiesVideo!.body.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            socialStudiesCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}

extension SocialStudiesVC: LoginStatusChecker {
    func logout() {
        isGuest = true
        print("SocialStudiesVC logout... current visibleIP : \(String(describing: visibleIP))")
        if let _ = visibleIP {
            stopCurrentVideoCell()
        }
    }
}
