//
//  LectureThumbnailCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import UIKit

class LectureThumbnailCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnail.contentMode = .scaleAspectFit
        thumbnail.sizeToFit()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
