/*
 하단 Cell 중 "노트보기" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class BottomNoteCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "노트보기"
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
        self.backgroundColor = .red
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
//        self.isUserInteractionEnabled = true
       // initialize what is needed
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
       // initialize what is needed
    }
}
