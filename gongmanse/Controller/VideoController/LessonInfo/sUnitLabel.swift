/*
 * Subclass UILabel 입니다.
 * 반복적으로 사용되는 UILabel 에 대해서 공통점을 추출하여 새롭게 생성했습니다.
 * 레이블 텍스트가 많아지면 그에 맞게 Width가 조절되도록 /* Width 조절 */ 에서 처리하고있습니다.
 * 그 바로 아래있는 코드가 텍스트 속성을 변경하는 부분입니다.
 */

import UIKit

class sUnitLabel: UILabel {

    internal var labelText: String? {
        didSet {
            commonInit()
        }
    }
    
    internal var labelBackgroundColor: UIColor? {
        didSet {
            commonInit()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    /// 레이블 초기화 메소드
    init(frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 20), _ labelText: String, _ labelColor: UIColor) {
        super.init(frame: frame)
        
        self.labelText = labelText
        if labelText != "TEST" {
            self.labelBackgroundColor = labelColor
        } else {
            self.alpha = 0
        }
        
        self.commonInit()
    }
    
    /// 레이블에 여백을 부여하는 메소드
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
    
    func commonInit() {
        
        // "DEFAULT" 인 경우, sUnit에 값이 없는 경우이고 그 경우 레이블이 안보이게한다.
        self.alpha = labelText == "DEFAULT" ? 0 : 1
        
        self.text = labelText! + "     "
        self.backgroundColor = labelBackgroundColor
    
        /* Width 조절 */
        let count = CGFloat(self.text!.count)
        let spacing = CGFloat(15)
        var width = count * 7.5
        width = self.text == "" ? 0 : width + spacing
        
        adjustsFontSizeToFitWidth = true
        
        /* Text 속성 부여 */
        self.font = UIFont.appBoldFontWith(size: 12)
        self.clipsToBounds = true
        self.layer.cornerRadius = 11.5
        self.textColor = .white
        self.textAlignment = .center
    }
}
