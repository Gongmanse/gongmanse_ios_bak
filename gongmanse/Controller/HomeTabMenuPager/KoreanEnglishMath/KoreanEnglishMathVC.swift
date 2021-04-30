import UIKit
import BottomPopup

protocol KoreanEnglishMathVCDelegate: class {
    func koreanPassSelectedIndexSettingValue(_ selectedIndex: Int)
    func koreanPassSortedIdSettingValue(_ sortedIndex: Int)
}

class KoreanEnglishMathVC: UIViewController, BottomPopupDelegate{
    
    var delegate: KoreanEnglishMathVCDelegate?
    
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
    var koreanEnglishMathVideo: VideoInput?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5
    
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
        textInput()
        cornerRadius()
        ChangeFontColor()
        
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
    
    func textInput() {
        //label에 지정된 text 넣기
        viewTitle.text = "국영수 강의"
        videoTotalCount.text = "총 11,000개"
    }
    
    func cornerRadius() {
        //전체보기 버튼 Border corner Radius 적용
        selectBtn.layer.cornerRadius = 10
        //전체보기 버튼 border width 적용
        selectBtn.layer.borderWidth = 2
        //전체보기 버튼 border 색상 적용
        selectBtn.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
    }
    
    func ChangeFontColor() {
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoTotalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: "11,000"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: "11,000"))
        
        self.videoTotalCount.attributedText = attributedString
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        playSwitch.onTintColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
    }
    
    func getDataFromJson() {
        if let url = URL(string: KoreanEnglishMath_Video_URL + "offset=0&limit=20&sortId=\(sortedId ?? 3)&type=\(selectedItem ?? 0)") {
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
                }
                
            }.resume()
        }
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
            return cell
            
        } else if selectedItem == 1 {
            // 시리즈 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
            return cell
            
        } else if selectedItem == 2 {
            // 문제 풀이
            setUpDefaultCellSetting()
            addKeywordToCell()
            return cell
        } else if selectedItem == 3 {
            // 노트 보기
            setUpDefaultCellSetting()
            addKeywordToCell()
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
        //나중에 추가
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 225)
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
            self.selectedItem = 2 // 시리즈 보기
        } else if selectedRowIndex == 2 {
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
        self.koreanEnglishMathCollection.reloadData()
    }
}

