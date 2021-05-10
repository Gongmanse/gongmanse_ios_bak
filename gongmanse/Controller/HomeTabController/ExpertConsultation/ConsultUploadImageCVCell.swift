import UIKit

class ConsultUploadImageCVCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var deleteImage: UIButton!
    
    var representedAssetIdentifier: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uploadImageView.layer.cornerRadius = 13
        uploadImageView.layer.borderWidth = 2.0
        uploadImageView.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        uploadImageView.backgroundColor = .clear
    }
}
