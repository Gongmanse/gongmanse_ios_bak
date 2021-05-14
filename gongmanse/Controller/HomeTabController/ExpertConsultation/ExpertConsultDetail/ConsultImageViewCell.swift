import UIKit

class ConsultImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var consultImageView: UIImageView!
    
    var receiveData: ExpertModelData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let defaultLink = fileBaseURL
        let thumbnailImageURL = receiveData?.sFilepaths ?? ""
        let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
        
        self.consultImageView.sd_setImage(with: thumbnailURL)
    }
}
