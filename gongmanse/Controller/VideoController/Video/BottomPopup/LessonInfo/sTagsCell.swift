import UIKit

class sTagsCell: UICollectionViewCell {
 
    //MARK: - Properties

    var cellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 14)
        label.text = "TEST"
        label.textColor = UIColor.rgb(red: 128, green: 128, blue: 128)
        label.textAlignment = .center
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
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
        
        backgroundColor = #colorLiteral(red: 0.9293201566, green: 0.9294758439, blue: 0.9292996526, alpha: 1)
        self.addSubview(cellLabel)
//        cellLabel.setDimensions(height: self.frame.height, width: self.frame.width)
//        cellLabel.centerX(inView: self)
//        cellLabel.centerY(inView: self)
        cellLabel.anchor(top: self.topAnchor,
                         left: self.leftAnchor,
                         bottom: self.bottomAnchor,
                         right: self.rightAnchor)
//        cellLabel.adjustsFontSizeToFitWidth = true
    }
    
}
