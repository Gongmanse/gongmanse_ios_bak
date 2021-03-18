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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
}
