//
//  ConfigurationCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/06.
//

import UIKit

class PushAlertCell: UITableViewCell {

    @IBOutlet weak var pushLabels: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pushLabels.font = UIFont(name: "NanumSquareRoundB", size: 14)
        pushLabels.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
