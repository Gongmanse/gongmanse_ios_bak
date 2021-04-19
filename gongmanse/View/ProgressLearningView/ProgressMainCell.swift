//
//  ProgressBottomCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit

class ProgressMainCell: UITableViewCell {

    @IBOutlet weak var gradeTitle: UILabel!
    @IBOutlet weak var totalRows: PaddingLabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var gradeLabel: PaddingLabel!
    @IBOutlet weak var subjectColor: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // 오른쪽
        // gradeTitle
        gradeTitle.font = .appBoldFontWith(size: 15)
        
        // total Label
        totalRows.backgroundColor = .rgb(red: 237, green: 118, blue: 0)
        totalRows.font = .appBoldFontWith(size: 12)
        totalRows.clipsToBounds = true
        totalRows.layer.cornerRadius = totalRows.frame.size.height / 2
        totalRows.textColor = .white
        
        // 왼쪽
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white

        // gradeLabel
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = gradeLabel.frame.size.height / 2
        
        // subjectColor
        subjectColor.backgroundColor = .mainOrange
        subjectColor.layer.cornerRadius = subjectColor.frame.size.height / 2
        subjectColor.layoutMargins = UIEdgeInsets(top: 2, left: 10, bottom: 3, right: 10)
        subjectColor.isLayoutMarginsRelativeArrangement = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


