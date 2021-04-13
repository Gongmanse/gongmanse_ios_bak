//
//  UseLectureCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/13.
//

import UIKit

class UseLectureCell: UITableViewCell {

    @IBOutlet weak var lectureImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lectureImage.contentMode = .scaleAspectFit
        lectureImage.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
