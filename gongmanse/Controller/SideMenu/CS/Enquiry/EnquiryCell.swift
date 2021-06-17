//
//  EnquiryCell.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/01.
//

import UIKit

class EnquiryCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var questionDescriptionLabel: UILabel!
    @IBOutlet weak var answerStateLabel: UILabel!
    @IBOutlet weak var questionDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        typeLabel.font = .appBoldFontWith(size: 12)
        questionDescriptionLabel.font = .appBoldFontWith(size: 14)
        answerStateLabel.font = .appBoldFontWith(size: 13)
        answerStateLabel.clipsToBounds = true
        answerStateLabel.layer.cornerRadius = 10
        answerStateLabel.textColor = .white
        questionDateLabel.font = .appBoldFontWith(size: 12)
        
        questionDateLabel.textColor = .rgb(red: 164, green: 164, blue: 164)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setList(type: OneOneQnADataList) {
        typeLabel.text = type.typeConvert
        questionDescriptionLabel.text = type.sQuestion
        answerStateLabel.backgroundColor = type.answerBackgroundColor
        answerStateLabel.text = type.answerStates
        questionDateLabel.text = type.dateConvert
        
    }
}
