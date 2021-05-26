//
//  EmptyTableViewCell.swift
//  gongmanse
//
//  Created by 김현수 on 2021/05/26.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.emptyLabel.font = UIFont.appBoldFontWith(size: 17)
        self.emptyLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
