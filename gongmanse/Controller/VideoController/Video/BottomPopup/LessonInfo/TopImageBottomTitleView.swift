import UIKit

class TopImageBottomTitleView: UIView {
    
    // MARK: - Properties

    lazy public var viewTintColor: UIColor = .black {
        didSet {
            imageView.tintColor = viewTintColor
            titleLabel.textColor = viewTintColor
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    public var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.tintColor = .black
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    public var button: UIButton = {
        let button = UIButton(type: .system)
        
        return button
    }()
    
    public var titleLabel = UILabel() {
        didSet {
            commonInit()
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    // MARK: - Lifecylce
    
    init(frame: CGRect, title: String, image: UIImage) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        let image = image
        image.withRenderingMode(.alwaysTemplate)
        self.titleLabel.text = title
        self.imageView.image = image
        self.imageView.tintColor = viewTintColor
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    // MARK: - Helpers
    
    private func commonInit(){
        let fontSize: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 15
        } else {
            fontSize = 12
        }
        
        self.addSubview(imageView)
        imageView.setDimensions(height: self.frame.height * 0.66,
                                width: self.frame.width)
        imageView.centerX(inView: self)
        imageView.anchor(top: self.topAnchor)
        
        self.addSubview(titleLabel)
        titleLabel.font = UIFont.appBoldFontWith(size: fontSize)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.centerX(inView: self)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLabel.anchor(top: imageView.bottomAnchor,
                              paddingTop: 10,
                              height: self.frame.height * 0.4)
        } else {
            titleLabel.anchor(top: imageView.bottomAnchor,
                              paddingTop: self.frame.height * 0.14,
                              height: self.frame.height * 0.3)
        }
    }
}
