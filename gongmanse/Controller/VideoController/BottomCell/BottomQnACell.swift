/*
 하단 Cell 중 "강의 QnA" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class BottomQnACell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "강의 QnA"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 40)
        return label
    }()

    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // initialize what is needed
        self.addSubview(label)
        self.backgroundColor = .white
        label.centerX(inView: self)
        label.centerY(inView: self)
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
}
