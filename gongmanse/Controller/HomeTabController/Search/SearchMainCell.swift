//
//  SearchMainCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//

import UIKit

class SearchMainCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = .appBoldFontWith(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
