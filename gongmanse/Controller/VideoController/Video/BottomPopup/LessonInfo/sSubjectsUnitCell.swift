import UIKit

class sSubjectsUnitCell: UICollectionViewCell {
 
    //MARK: - Properties

    let cellLabel: UILabel = {
        let fontSize: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                fontSize = 18
            } else {
                fontSize = 16
            }
        } else {
            fontSize = 14
        }
        
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: fontSize)
        label.text = "TEST"
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        configure()
        self.backgroundColor = .green
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure() {
        self.addSubview(cellLabel)
        cellLabel.setDimensions(height: 20, width: self.frame.width)
        cellLabel.centerX(inView: self)
        cellLabel.centerY(inView: self)
        cellLabel.sizeToFit()
    }
    
}
