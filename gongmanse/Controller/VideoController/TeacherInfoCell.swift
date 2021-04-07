//
//  TeacherInfoCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/05.
//

import UIKit

class TeacherInfoCell: UITableViewCell {
    
    
    //MARK: - Lifecycle
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.backgroundColor = .red
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
}
