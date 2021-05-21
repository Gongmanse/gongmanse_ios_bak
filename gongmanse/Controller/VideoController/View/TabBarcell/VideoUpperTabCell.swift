/*
 상단탭바의 Cell에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class VideoUpperCell: UICollectionViewCell {
    
    public var label: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 28, green: 28, blue: 28)
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 14)
        return label
    }()
    
    public var leftImageView = UIImageView()
    
    
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // initialize what is needed
        self.addSubview(label)
        self.backgroundColor = .white
        label.centerX(inView: self)
        label.centerY(inView: self)
        
        self.addSubview(leftImageView)
        leftImageView.setDimensions(height: 22, width: 23.4)
        leftImageView.centerY(inView: label)
        leftImageView.anchor(right: label.leftAnchor,
                             paddingRight: 5)
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
    
    override var isSelected: Bool {
        didSet{
            print("Changed")
            self.label.textColor = isSelected ? .mainOrange : .rgb(red: 28, green: 28, blue: 28)
        }
    }
}
