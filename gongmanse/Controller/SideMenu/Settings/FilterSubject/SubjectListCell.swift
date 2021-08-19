//
//  SubjectListCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/08.
//

import UIKit

class SubjectListCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var ivChk: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subjectLabel.font = UIFont(name: "NanumSquareRoundB", size: 14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
