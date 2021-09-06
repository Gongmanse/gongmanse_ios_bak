//
//  QnAMyChatCell.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import UIKit

class QnAMyChatCell: UITableViewCell {

    @IBOutlet weak var myProfile: UIImageView!
    @IBOutlet weak var myContent: PaddingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        myProfile.layer.cornerRadius = 10
        myContent.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
