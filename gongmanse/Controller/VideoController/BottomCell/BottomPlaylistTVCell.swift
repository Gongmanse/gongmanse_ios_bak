//
//  BottomPlaylistTVCell.swift
//  gongmanse
//
//  Created by 김현수 on 2021/05/17.
//

import UIKit

class BottomPlaylistTVCell: UITableViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var subjects: PaddingLabel!
    @IBOutlet weak var term: PaddingLabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var starRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
        
        // 안드로이드에 평점이 없으므로 UI변경 06.11
        starRating.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
