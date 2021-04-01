//
//  QuestionListCell.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/31.
//

import UIKit

class QuestionListCell: UITableViewCell {

    @IBOutlet weak var askMarkLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        askMarkLabel.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        askMarkLabel.sizeToFit()
        
        askLabel.font = UIFont(name: "NanumSquareRoundB", size: 14)
        askLabel.sizeToFit()

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
}
