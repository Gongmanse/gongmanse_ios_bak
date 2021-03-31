//
//  QuestionListCell.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/31.
//

import UIKit

class QuestionListCell: UITableViewCell {

    @IBOutlet weak var questionMarkLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        questionMarkLabel.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        questionLabel.font = UIFont(name: "NanumSquareRoundE", size: 14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
