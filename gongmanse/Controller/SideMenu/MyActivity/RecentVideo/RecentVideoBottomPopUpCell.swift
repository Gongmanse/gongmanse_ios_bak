//
//  RecentVideoBottomPopUpCell.swift
//  gongmanse
//
//  Created by 김현수 on 2021/06/01.
//

import UIKit

class RecentVideoBottomPopUpCell: UITableViewCell {

    @IBOutlet weak var selectTitle: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
