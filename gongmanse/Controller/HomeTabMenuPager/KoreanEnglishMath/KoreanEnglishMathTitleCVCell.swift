import UIKit
import BottomPopup

protocol KoreanEnglishMathTitleCVCellDelegate: class {
    func presentBottomPopUp()
}

class KoreanEnglishMathTitleCVCell: UICollectionReusableView, BottomPopupDelegate {
    
    // Properties
    var delegate: KoreanEnglishMathTitleCVCellDelegate?
    
    var height: CGFloat = 300
    
    var presentDuration: Double = 0.2
    
    var dismissDuration: Double = 0.5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
