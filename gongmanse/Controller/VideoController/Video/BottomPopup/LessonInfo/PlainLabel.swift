import UIKit

class PlainLabel: UILabel {

    internal var labelText: String? {
        didSet { commonInit() }
    }
    
    internal var labelBackgroundColor: UIColor? {
        didSet { commonInit() }
    }
    
    internal var fontSize: CGFloat? {
        didSet { commonInit() }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    init(frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 20),
         _ labelText: String,
         fontSize: CGFloat? = 11,
         _ labelColor: UIColor? = .clear) {
        super.init(frame: frame)
        self.labelText = labelText
        self.labelBackgroundColor = labelColor
        self.fontSize = fontSize
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.fontSize = fontSize! + 2
        }
        self.commonInit()
    }
    
    func commonInit() {
    
        self.text = labelText!
        self.backgroundColor = labelBackgroundColor
        adjustsFontSizeToFitWidth = true
        
        /* Text 속성 부여 */
        self.font = UIFont.appBoldFontWith(size: fontSize!)
        self.clipsToBounds = true
        self.textColor = .black
        self.textAlignment = .center
    }
}
