import UIKit
import BottomPopup

protocol KoreanEnglishMathVCDelegate: AnyObject {
    func koreanPassSelectedIndexSettingValue(_ selectedIndex: Int)
    func koreanPassSortedIdSettingValue(_ sortedIndex: Int)
}

class KoreanEnglishMathVC: UIViewController, BottomPopupDelegate{
    
    // 자동재생기능 구현을 위한 싱글톤객체를 생성한다.
    let autoplayDataManager = AutoplayDataManager.shared

    var delegate: KoreanEnglishMathVCDelegate?

    var problemSolvingListData: FilterVideoModels? {
        didSet {
            if let input = problemSolvingListData {
                autoplayDataManager.videoDataInMainSubjectsProblemSolvingTab = input
            }
            
        }
    }
    
    // TODO: 추후에 "나의 설정" 완성 시, 설정값을 이 프로퍼티로 할당할 것.
    /// 설정창에서 등록한 Default 학년 / 과목으로 변경 시, API를 그에 맞게 호출하는 연산프로퍼티
    var selectedItem: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var sortedId: Int? {
        didSet {
            getDataFromJson()
        }
    }
    
    var pageIndex: Int!
    var koreanEnglishMathVideo: VideoInput? {
        didSet {
            if let krEnMathData = koreanEnglishMathVideo {
                self.autoplayDataManager.videoDataInMainSubjectsTab = krEnMathData
            }
        }
    }
    var koreanEnglishMathVideoSecond: FilterVideoModels?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
    @IBOutlet weak var autoPlayLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var ratingSequence: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var koreanEnglishMathCollection: UICollectionView!
    
    let koreanEnglishMathRC: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refresh(sender: UIRefreshControl) {
        koreanEnglishMathCollection.reloadData()
        sender.endRefreshing()
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rateFilterNoti(_:)), name: NSNotification.Name("rateFilterText"), object: nil)
        
        
        // 셀등록
        koreanEnglishMathCollection.register(UINib(nibName: "TeacherPlaylistCell", bundle: nil), forCellWithReuseIdentifier: TeacherPlaylistCell.reusableIdentifier)
    }
    
    @objc func videoFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "videoFilterText")
        selectBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    @objc func rateFilterNoti(_ sender: NotificationCenter) {
        let rateFilterButtonTitle = UserDefaults.standard.object(forKey: "rateFilterText")
        ratingSequence.setTitle(rateFilterButtonTitle as? String, for: .normal)
    }
    
    /// 자동재생 설정 여부를 확인하기 위한 콜백메소드
    @objc func playSwitchValueChanged(_ sender: UISwitch) {
        autoplayDataManager.isAutoplayMainSubject = sender.isOn
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
    }
    
    func ChangeSwitchButton() {
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        playSwitch.onTintColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
    }
    
    func getDataFromJson() {
        var default1 = 0
        if let url = URL(string: KoreanEnglishMath_Video_URL + "offset=\(default1)&limit=20&sortId=\(sortedId ?? 3)&type=\(selectedItem ?? 0)") {
            default1 += 20
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
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
        }
    }
    
    func getDataFromJsonSecond() {
        if let url = URL(string: "https://api.gongmanse.com/v/video/bycategory?category_id=34&commentary=\(selectedItem ?? 0)&sort_id=\(sortedId ?? 3)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    //print(json.body)
                    self.koreanEnglishMathVideoSecond = json
                    
                    // 문제풀이인 경우,
                    if self.selectedItem == 2 {
                        self.problemSolvingListData = json
                    }
                    
                }
                DispatchQueue.main.async {
                    self.koreanEnglishMathCollection.reloadData()
                    self.textSettings()
                }

            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.koreanEnglishMathVideo?.header else { return }
        
        self.videoTotalCount.text = "총 \(value.totalRows ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoTotalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])

        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: value.totalRows!))

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
            cell.videoThumbnail.contentMode = .scaleAspectFill
            cell.videoThumbnail.sd_setImage(with: url)
            cell.videoTitle.text = indexData.title
            cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
            cell.subjects.text = indexData.subject
            cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
            cell.starRating.text = indexData.rating
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
            return cell
            
        } else if selectedItem == 1 {
            // 시리즈 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = false
            autoPlayLabel.isHidden = false
            return cell
            
        } else if selectedItem == 2 {
            // 문제 풀이
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = true
            autoPlayLabel.isHidden = true
            return cell
        } else if selectedItem == 3 {
            // 노트 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            playSwitch.isHidden = true
            autoPlayLabel.isHidden = true
            return cell
            
        } else {
            // 전체 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            return cell
        }
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Constant.isLogin {
            
            // 시리즈보기: self.selectedItem == 1
            // 문제풀이: self.selectedItem == 2
            // 전체보기
            if self.selectedItem == 0 {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                videoDataManager.isFirstPlayVideo = true
                vc.modalPresentationStyle = .fullScreen
                let videoID = koreanEnglishMathVideo?.body[indexPath.row].videoId
                vc.id = videoID
                let seriesID = koreanEnglishMathVideoSecond?.data[indexPath.row].iSeriesId
                vc.koreanSeriesId = seriesID
                vc.koreanSwitchValue = playSwitch
                vc.koreanReceiveData = koreanEnglishMathVideo
                vc.koreanSelectedBtn = selectBtn
//                vc.koreanViewTitle = viewTitle.text
                vc.koreanViewTitle = "국영수 강의"
                autoplayDataManager.currentViewTitleView = "국영수 강의"
                present(vc, animated: true)
                
                
            // 문제풀이
            } else if self.selectedItem == 1 {
                print("DEBUG: 1번")
            
            // 시리즈보기
            } else if self.selectedItem == 2 {

                print("DEBUG: 2번")
            // 노트보기
            } else if self.selectedItem == 3 {
                let videoID = koreanEnglishMathVideo?.body[indexPath.row].videoId
                let vc = LessonNoteController(id: "\(videoID!)", token: Constant.token)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                print("DEBUG: 3번")
            }

            
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
        
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
        let width = view.frame.width - 40
        return CGSize(width: width, height: 265)
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
    
    func passSortedIdRow(_ sortedIdRowIndex: Int) {
        
        if sortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 3 // 평점순
        } else if sortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 4 // 최신순
        } else if sortedIdRowIndex == 2 {   // 3 번째 Cell
            self.sortedId = 1 // 이름순
        } else {                            // 4 번째 Cell
            self.sortedId = 2 // 과목순
        }
        
        self.delegate?.koreanPassSortedIdSettingValue(sortedIdRowIndex)
        self.koreanEnglishMathCollection.reloadData()
        
    }
    
    func passSelectedRow(_ selectedRowIndex: Int) {
        
        if selectedRowIndex == 0 {
            self.selectedItem = 0 // 전체 보기
        } else if selectedRowIndex == 1 {
            self.selectedItem = 1 // 시리즈 보기
        } else if selectedRowIndex == 2 {
            self.selectedItem = 2 // 문제 풀이
        } else {
            self.selectedItem = 3 // 노트 보기
        }
        // 클릭한 indexRow에 맞는 index를 "KoreanEnglishMathVC"의 프로퍼티에 전달한다.
//        self.selectedItem = selectedRowIndex
        self.delegate?.koreanPassSelectedIndexSettingValue(selectedRowIndex)
        // 변경된 selectedItem으로 다시 API를 호출한다.
//        getDataFromJson()
        // collectionview를 업데이트한다.
        self.koreanEnglishMathCollection.reloadData()
    }
}

