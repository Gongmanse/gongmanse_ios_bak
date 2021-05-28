/*
 하단 Cell 중 "노트보기" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class BottomNoteCell: UICollectionViewCell {
    
    public var view = UIView()
    
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
//        self.addSubview(label)
//        self.backgroundColor = .white
//        label.centerX(inView: self)
//        label.centerY(inView: self)
//        self.backgroundColor = .red
        
        self.addSubview(view)
        view.backgroundColor = .white
        view.anchor(top: self.topAnchor,
                    left: self.leftAnchor,
                    bottom: self.bottomAnchor,
                    right: self.rightAnchor)
        
//        let noteVC = LectureNoteController(id: "46654", token: Constant.token)
//        view.addSubview(noteVC.view)
//        noteVC.view.anchor(top: view.topAnchor,
//                           left: view.leftAnchor,
//                           bottom: view.bottomAnchor,
//                           right: view.rightAnchor)
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
