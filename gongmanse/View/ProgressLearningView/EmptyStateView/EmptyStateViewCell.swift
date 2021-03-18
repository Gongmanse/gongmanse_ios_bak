//
//  EmptyStateViewCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/09.
//

import UIKit

class EmptyStateViewCell: UITableViewCell {

    @IBOutlet weak var alertMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alertMessage.font = UIFont.appBoldFontWith(size: 17)
        self.alertMessage.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
}
