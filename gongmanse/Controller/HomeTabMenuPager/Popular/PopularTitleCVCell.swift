import UIKit

class PopularTitleCVCell: UICollectionReusableView {
    
    @IBOutlet weak var viewTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewTitle.text = "인기HOT! 동영상 강의"
        
        let attributedString = NSMutableAttributedString(string: viewTitle.text!, attributes: [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (viewTitle.text! as NSString).range(of: "HOT!"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: (viewTitle.text! as NSString).range(of: "HOT!"))
        
        self.viewTitle.attributedText = attributedString
    }
}
