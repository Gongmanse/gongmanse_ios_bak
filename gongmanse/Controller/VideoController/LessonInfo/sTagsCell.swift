import UIKit

class sTagsCell: UICollectionViewCell {
 
    //MARK: - Properties

    var cellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 10)
        label.text = "TEST"
        label.textColor = UIColor.rgb(red: 128, green: 128, blue: 128)
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
       // initialize what is needed
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
       // initialize what is needed
    }
    
    
    func configure() {
        
        self.addSubview(cellLabel)
        cellLabel.setDimensions(height: self.frame.height, width: self.frame.width)
        cellLabel.centerX(inView: self)
        cellLabel.centerY(inView: self)
        cellLabel.adjustsFontSizeToFitWidth = true
    }
    
}
