import UIKit
import BottomPopup

protocol OtherSubjectsVCDelegate: class {
    func otherSubjectsPassSelectedIndexSettingValue(_ selectedIndex: Int)
    func otherSubjectsPassSortedIdSettingValue(_ sortedIndex: Int)
}

class OtherSubjectsVC: UIViewController, BottomPopupDelegate, subjectVideoListInfinityScroll {
    
    
    var delegate: OtherSubjectsVCDelegate?
    let autoPlayDataManager = AutoplayDataManager.shared
    
    // TODO: 추후에 "나의 설정" 완성 시, 설정값을 이 프로퍼티로 할당할 것.
    /// 설정창에서 등록한 Default 학년 / 과목으로 변경 시, API를 그에 맞게 호출하는 연산프로퍼티
    var selectedItem: Int? {
        didSet {
            listCount = 0
            getDataFromJson()
        }
    }
    
    var sortedId: Int? {
        didSet {
            listCount = 0
            getDataFromJson()
        }
    }
    
    var pageIndex: Int!
    var otherSubjectsVideo: VideoInput? {
        didSet {
            if let inputData = otherSubjectsVideo {
                autoPlayDataManager.videoDataInOtherSubjectsTab = inputData
            }
        }
    }
    
    
    
    var otherSubjectsVideoSecond: FilterVideoModels?
    var noteShow: FilterVideoModels?
    
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
    @IBOutlet weak var otherSubjectsCollection: UICollectionView!
    
    var detailVideo: DetailSecondVideoResponse?
    var detailData: DetailVideoInput?
    var detailVideoData: DetailSecondVideoData?
    
    var inputFilterNum = 0
    var inputSortNum = 4
    
    private let cellIdentifier = "KoreanEnglishMathAllSeriesCell"
    
    //collectionView 새로고침
    let otherSubjectsRC: UIRefreshControl = {
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
        otherSubjectsCollection.reloadData()
        sender.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherSubjectsCollection.refreshControl = otherSubjectsRC
        
        getDataFromJson()
        getDataFromJsonSecond()
        getDataFromJsonVideo()
        textInput()
        cornerRadius()
        changeSwitchButton()
        
        autoPlayLabel.isHidden = true
        playSwitch.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rateFilterNoti(_:)), name: NSNotification.Name("rateFilterText"), object: nil)
        
        playSwitch.addTarget(self, action: #selector(autoPlaySwitchDidTap(_:)), for: .valueChanged)
        
        //xib 셀 등록
        otherSubjectsCollection.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func getDataFromJsonVideo() {
        
        //guard let videoId = data?.video_id else { return }
        
        if let url = URL(string: "https://api.gongmanse.com/v/video/details?video_id=9316&token=\(Constant.token)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(DetailSecondVideoResponse.self, from: data) {
                    //print(json.data)
                    self.detailVideo = json
                    self.detailVideoData = json.data
                }
                DispatchQueue.main.async {
                    self.otherSubjectsCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    
    // MARK: - Actions
    
    @objc func videoFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "videoFilterText")
        selectBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    @objc func rateFilterNoti(_ sender: NotificationCenter) {
        let rateFilterButtonTitle = UserDefaults.standard.object(forKey: "rateFilterText")
        filteringBtn.setTitle(rateFilterButtonTitle as? String, for: .normal)
    }
    
    @objc func autoPlaySwitchDidTap(_ sender: UISwitch) {
        
        let autoplayDataManager = AutoplayDataManager.shared
        autoplayDataManager.isAutoplayOtherSubjects = sender.isOn
    }
    
    // MARK: - Helper
    
    func textInput() {
        //label에 지정된 text 넣기
        viewTitle.text = "기타 강의"
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
    
    func changeSwitchButton() {
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
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
        
        if let url = URL(string: OtherSubjects_Video_URL + "offset=\(listCount)&limit=20&sortId=\(inputSortNum)&type=\(inputFilterNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        //print(json.body)
                        self.otherSubjectsVideo = json
                    }
                    DispatchQueue.main.async {
                        self.otherSubjectsCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(VideoInput.self, from: data) {
                        
                        for i in 0..<json.body.count {
                            self.otherSubjectsVideo?.body.append(json.body[i])
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.otherSubjectsCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            }
        }
    }
    
    func getDataFromJsonSecond() {
        //        if let url = URL(string: "https://api.gongmanse.com/v/video/bycategory?category_id=37&commentary=\(selectedItem ?? 0)&sort_id=\(sortedId ?? 3)&limit=20") {
        if let url = URL(string: "https://api.gongmanse.com/v/video/bycategory?category_id=37&commentary=\(selectedItem ?? 0)&sort_id=\(sortedId ?? 3)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            if listCount == 0 {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        self.otherSubjectsVideoSecond = json
                    }
                    DispatchQueue.main.async {
                        self.otherSubjectsCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            } else {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                        
                        for i in 0..<json.data.count {
                            self.otherSubjectsVideoSecond?.data.append(json.data[i])
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.otherSubjectsCollection.reloadData()
                        self.textSettings()
                    }
                    
                }.resume()
            }
        }
    }
    
    func textSettings() {
        guard let value = self.otherSubjectsVideo?.header else { return }
        
        self.videoTotalCount.text = "총 \(value.totalRows ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoTotalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))
        
        self.videoTotalCount.attributedText = attributedString
    }
    
    func getDataFromJsonNote() {
        if let url = URL(string: "https://api.gongmanse.com/v/video/notelist?category_id=37&offset=0&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.noteShow = json
                    
                }
                DispatchQueue.main.async {
                    self.otherSubjectsCollection.reloadData()
                }
            }.resume()
        }
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

extension OtherSubjectsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.otherSubjectsVideo?.body else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherSubjectsCVCell", for: indexPath) as! OtherSubjectsCVCell
        guard let json = self.otherSubjectsVideo else { return cell }
        
        let indexData = json.body[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(indexData.thumbnail ?? "nil"))
        
        /// cell UI업데이트를 위한 메소드
        func setUpDefaultCellSetting() {
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.title
            cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
            cell.subjects.text = indexData.subject
            cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
            cell.starRating.text = indexData.rating
            cell.videoPlayButton.addTarget(self, action: #selector(videoPlay(_:)), for: .touchUpInside)
            cell.videoPlayButton.isHidden = true
            cell.videoPlayButton.tag = indexPath.row
        }
        
        /// cell keyword 업데이트를 위한 메소드
        func addKeywordToCell() {
            if indexData.unit != nil {
                cell.term.isHidden = false
                cell.term.text = indexData.unit
            } else if indexData.unit == "1" {
                cell.term.isHidden = false
                cell.term.text = "i"
            } else if indexData.unit == "2" {
                cell.term.isHidden = false
                cell.term.text = "ii"
            } else {
                cell.term.isHidden = true
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
            guard let json = self.otherSubjectsVideo else { return cell }
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
            
            guard let value = self.otherSubjectsVideo else { return }
            let data = value.body
            print("data is \(data)")
            print("senderTag is \(sender.tag)")
            //            guard let selectedVideoIndex = self.selectedRow else { return }
            //            print("slectedRow is \(selectedVideoIndex)")
            let vc = VideoController()
            vc.id = data[sender.tag].videoId
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
                sleep(1)
            }
        }
    }
}

extension OtherSubjectsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
        
        guard let indexVideoData = detailVideo?.data else { return }
        
        if indexVideoData.source_url == nil {
            presentAlert(message: "이용권을 구매해주세요")
            
        } else if indexVideoData.source_url != nil {
            
            if self.selectedItem == 0 {
                let vc = VideoController()
                vc.modalPresentationStyle = .fullScreen
                let videoID = otherSubjectsVideo?.body[indexPath.row].videoId
                vc.id = videoID
                let seriesID = otherSubjectsVideoSecond?.data[indexPath.row].iSeriesId
                vc.otherSubjectsSeriesId = seriesID
                vc.otherSubjectsSwitchValue = playSwitch
                vc.otherSubjectsReceiveData = otherSubjectsVideo
                vc.otherSubjectsSelectedBtn = selectBtn
                vc.otherSubjectsViewTitle = "기타 강의"
                let autoDataManager = AutoplayDataManager.shared
                autoDataManager.currentViewTitleView = "기타"
                present(vc, animated: true)
            } else if self.selectedItem == 1 {
                let vc = self.storyboard?.instantiateViewController(identifier: "SeriesVC") as! SeriesVC
                let seriesID = otherSubjectsVideo?.body[indexPath.row].seriesId
                vc.receiveSeriesId = seriesID
                vc.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(vc, animated: true)
                print("DEBUG: 1번")
            } else if self.selectedItem == 2 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                videoDataManager.isFirstPlayVideo = true
                vc.modalPresentationStyle = .fullScreen
                let videoID = otherSubjectsVideo?.body[indexPath.row].videoId
                vc.id = videoID
                let seriesID = otherSubjectsVideoSecond?.data[indexPath.row].iSeriesId
                vc.socialStudiesSeriesId = seriesID
                vc.socialStudiesSwitchValue = playSwitch
                vc.socialStudiesReceiveData = otherSubjectsVideo
                vc.socialStudiesSelectedBtn = selectBtn
                //                vc.koreanViewTitle = viewTitle.text
                vc.socialStudiesViewTitle = "기타"
                //                autoplayDataManager.currentViewTitleView = "국영수 강의"
                let autoDataManager = AutoplayDataManager.shared
                autoDataManager.currentFiltering = "문제 풀이"
                present(vc, animated: true)
                print("DEBUG: 2번")
            } else if self.selectedItem == 3 {
                let videoID = otherSubjectsVideo?.body[indexPath.row].videoId
                let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
                
                // 노트 전체보기 화면에 SeriesID가 필요
                if let seriesID = noteShow?.data[indexPath.row].iSeriesId {
                    vc.seriesID = seriesID
                }
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                print("DEBUG: 3번")
                
            }
            
        } else if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
            return
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = otherSubjectsVideo?.body.count else { return }
        
        guard let cellCountSecond = otherSubjectsVideoSecond?.data.count else { return }
        
        if indexPath.row == cellCount - 1 {
            listCount += 20
            getDataFromJson()
        } else if indexPath.row == cellCountSecond - 1 {
            listCount += 20
            getDataFromJsonSecond()
        }
    }
}

extension OtherSubjectsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        
        //0707 - edited by hp
        return CGSize(width: width, height: (width / 16 * 9 + 70))
    }
}

// MARK: - KoreanEnglishMathBottomPopUpVCDelegate
/// 필터 메뉴를 클릭하면, 호출되는 메소드 구현을 위한 `extension`
extension OtherSubjectsVC: KoreanEnglishMathBottomPopUpVCDelegate, KoreanEnglishMathAlignmentVCDelegate {
    
    func passSortedIdRow(_ sortedIdRowIndex: Int) {
        
        if sortedIdRowIndex == 2 {          // 1 번째 Cell
            self.sortedId = 2 // 평점순
        } else if sortedIdRowIndex == 3 {   // 2 번째 Cell
            self.sortedId = 3 // 최신순
        } else if sortedIdRowIndex == 0 {   // 3 번째 Cell
            self.sortedId = 0 // 이름순
        } else {                            // 4 번째 Cell
            self.sortedId = 1 // 과목순
        }
        
        self.delegate?.otherSubjectsPassSortedIdSettingValue(sortedIdRowIndex)
        self.otherSubjectsCollection.reloadData()
    }
    
    func passSelectedRow(_ selectedRowIndex: Int) {
        
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
        self.delegate?.otherSubjectsPassSelectedIndexSettingValue(selectedRowIndex)
        // 변경된 selectedItem으로 다시 API를 호출한다.
        //        getDataFromJson()
        // collectionview를 업데이트한다.
        self.otherSubjectsCollection.reloadData()
    }
}
