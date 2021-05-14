//
//  QnAOthersChatCell.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import UIKit

class QnAOthersChatCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var stackColor: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
