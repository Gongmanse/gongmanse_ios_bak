//
//  GradeListCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/08.
//

import UIKit

class GradeListCell: UITableViewCell {

    @IBOutlet weak var gradeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradeLabel.font = UIFont(name: "NanumSquareRoundB", size: 14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
