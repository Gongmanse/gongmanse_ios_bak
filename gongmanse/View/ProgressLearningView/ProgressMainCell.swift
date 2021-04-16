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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // gradeTitle
        gradeTitle.font = .appBoldFontWith(size: 15)
        
        // total Label
        totalRows.backgroundColor = .rgb(red: 237, green: 118, blue: 0)
        totalRows.font = .appBoldFontWith(size: 12)
        totalRows.clipsToBounds = true
        totalRows.layer.cornerRadius = totalRows.frame.size.height / 2
        totalRows.textColor = .white
        
        totalRows.topInset = 4
        totalRows.bottomInset = 4
        totalRows.leftInset = 6
        totalRows.rightInset = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


