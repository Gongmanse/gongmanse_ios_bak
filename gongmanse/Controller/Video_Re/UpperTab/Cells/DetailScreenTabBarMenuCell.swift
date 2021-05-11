//
//  DetailScreenTabBarMenuCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import Foundation
import UIKit

class DetailScreenTabBarMenuCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 28, green: 28, blue: 28)
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 14)
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
    
    override var isSelected: Bool {
        didSet{
            print("Changed")
            self.label.textColor = isSelected ? .mainOrange : .rgb(red: 28, green: 28, blue: 28)
        }
    }
}
