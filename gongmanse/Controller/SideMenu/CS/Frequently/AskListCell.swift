//
//  AskListCell.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/01.
//

import UIKit

class AskListCell: UITableViewCell {

    @IBOutlet weak var askTextLabel: UILabel!
    @IBOutlet weak var askMarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        askTextLabel.font = .appBoldFontWith(size: 14)
        askTextLabel.sizeToFit()
        
        askMarkLabel.font = .appBoldFontWith(size: 14)
        askMarkLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
