//
//  QnAOthersChatCell.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import UIKit

class QnAOthersChatCell: UITableViewCell {

    @IBOutlet weak var otherProfile: UIImageView!
    @IBOutlet weak var otherContent: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        otherProfile.layer.cornerRadius = 10
//        otherContent.layer.cornerRadius = 10
        bubbleView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
