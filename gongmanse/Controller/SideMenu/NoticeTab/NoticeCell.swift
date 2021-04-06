//
//  NoticeCell.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/05.
//

import UIKit

class NoticeCell: UICollectionViewCell {

    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var createContentDate: UILabel!
    @IBOutlet weak var contentViewer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentImage.layer.cornerRadius = 10
        contentImage.sizeToFit()
        contentImage.contentMode = .scaleAspectFill
        
        contentTitle.font = UIFont(name: "NanumSquareRoundB", size: 14)
        
        createContentDate.font = UIFont(name: "NanumSquareRoundB", size: 12)
        createContentDate.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)
        
        contentViewer.font = UIFont(name: "NanumSquareRoundB", size: 12)
        contentViewer.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)
        
    }

}
