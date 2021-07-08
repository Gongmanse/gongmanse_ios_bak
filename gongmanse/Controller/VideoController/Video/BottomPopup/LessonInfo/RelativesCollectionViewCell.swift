import UIKit

class RelativesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subject: PaddingLabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
