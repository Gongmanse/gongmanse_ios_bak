//
//  EventListCell.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import UIKit

class EventListCell: UICollectionViewCell {

    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentViewer: UILabel!
    @IBOutlet weak var contentCreateDate: UILabel!
    @IBOutlet weak var isDisplayStats: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지
        contentImage.layer.cornerRadius = 10
        contentImage.sizeToFit()
        contentImage.contentMode = .scaleAspectFill
        
        // 타이틀
        contentTitle.font = UIFont(name: "NanumSquareRoundB", size: 14)
        
        // 조회수
        contentViewer.font = UIFont(name: "NanumSquareRoundB", size: 12)
        contentViewer.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)

        // 날짜
        contentCreateDate.font = UIFont(name: "NanumSquareRoundB", size: 12)
        contentCreateDate.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)
        
        //display 설정 전
                
    }

}
