import UIKit
import BottomPopup

class KoreanEnglishMathVC: UIViewController, BottomPopupDelegate, KoreanEnglishMathAlignmentVCDelegate {
        
    var selectedItem: Int?
    
    var pageIndex: Int!
    var koreanEnglishMathVideo: KoreanEnglishVideoInput?
    
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
        
        getDataFromJson()
        textInput()
        cornerRadius()
        ChangeFontColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFilterNoti(_:)), name: NSNotification.Name("videoFilterText"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rateFilterNoti(_:)), name: NSNotification.Name("rateFilterText"), object: nil)
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
        if let url = URL(string: KoreanEnglishMath_Video_URL) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(KoreanEnglishVideoInput.self, from: data) {
                    //print(json.data)
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
        popupVC.selectItem = self.selectedItem
        present(popupVC, animated: true)
    }
}

extension KoreanEnglishMathVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.koreanEnglishMathVideo?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanEnglishMathCVCell", for: indexPath) as! KoreanEnglishMathCVCell
        guard let json = self.koreanEnglishMathVideo else { return cell }
        
        let indexData = json.data[indexPath.row]
        let defaultLink = fileBaseURL
        let url = URL(string: makeStringKoreanEncoded(defaultLink + "/" + indexData.sThumbnail))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.teachersName.text = indexData.sTeacher + " 선생님"
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)
        cell.starRating.text = indexData.iRating
        
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
        return cell
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

extension KoreanEnglishMathVC: KoreanEnglishMathBottomPopUpVCDelegate {
    func passSecltedRow(_ selectedRowIndex: Int) {
        self.selectedItem = selectedRowIndex
    }
    
    
}
