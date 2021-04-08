import UIKit
import BottomPopup

protocol KoreanEnglishMathTitleCVCellDelegate: class {
    func presentBottomPopUp()
}

class KoreanEnglishMathTitleCVCell: UICollectionReusableView, BottomPopupDelegate {
    
    // Properties
    var delegate: KoreanEnglishMathTitleCVCellDelegate?
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var ratingSequence: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    
    var height: CGFloat = 300
    
    var presentDuration: Double = 0.2
    
    var dismissDuration: Double = 0.5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textInput()
        cornerRadius()
        ChangeFontColor()
    }
    
    func textInput() {
        //label에 지정된 text 넣기
        viewTitle.text = "국영수 강의"
        videoTotalCount.text = "총 11,000개"
    }
    
    func cornerRadius() {
        //전체보기 버튼 Border corner Radius 적용
        selectBtn.layer.cornerRadius = 11
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
    
    @IBAction func presentPopUpMenu(_ sender: Any) {
        
        let popupVC = KoreanEnglishMathBottomPopUpVC()
        popupVC.height = height
        print(height)
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        // TODO: BottomPopUP 호출
        delegate?.presentBottomPopUp()
    }
}
