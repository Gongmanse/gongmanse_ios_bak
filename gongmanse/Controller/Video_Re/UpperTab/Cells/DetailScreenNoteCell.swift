//
//  DetailScreenNoteCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import Foundation
import UIKit

class DetailScreenNotecell: UICollectionViewCell {
    
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
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
        self.isUserInteractionEnabled = true
       // initialize what is needed
    }

}
