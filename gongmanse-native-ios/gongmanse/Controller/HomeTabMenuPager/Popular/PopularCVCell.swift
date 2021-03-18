import UIKit

class PopularCVCell: UICollectionViewCell {
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var starRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoThumbnail.layer.cornerRadius = 13
        teachersName.textColor = UIColor.black
    }
}
