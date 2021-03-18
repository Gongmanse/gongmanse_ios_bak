import UIKit

class KoreanEnglishMathTitleCVCell: UICollectionReusableView {
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var ratingSequence: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewTitle.text = "국영수 강의"
        
        //test 끝나면 지움
        
        
    }
}
