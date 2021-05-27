//
//  LectureCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

class LectureCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var mainImageView: UIImageView!  // 강의 미리보기 이미지
    @IBOutlet weak var view: UIView!                // cell 전체 뷰
    @IBOutlet weak var bottomView: UIView!          // 하단 뷰
    @IBOutlet weak var lectureTitle: UILabel!       // 강의명
    @IBOutlet weak var teachername: UILabel!        // 선생명
    @IBOutlet weak var tagLabel: UILabel!           // 태그명
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    
    func setSeriesCellData(_ type: SeriesDetailDataModel) {
        mainImageView.setImageUrl("\(fileBaseURL)/\(type.sThumbnail ?? "")")
        mainImageView.contentMode = .scaleAspectFill
        lectureTitle.text = type.sTitle
        teachername.text = type.sTeacher
        tagLabel.text = type.sSubject
        tagLabel.backgroundColor = UIColor(hex: type.sSubjectColor ?? "000000")
    }
    
    func setVideoCellData(_ type: RelationSeriesDataModel) {
        mainImageView.setImageUrl("\(fileBaseURL)/\(type.sThumbnail)")
        mainImageView.contentMode = .scaleAspectFill
        lectureTitle.text = type.sTitle
        teachername.text = type.sTeacher
        tagLabel.text = type.sSubject
        tagLabel.backgroundColor = UIColor(hex: type.sSubjectColor)
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        let frame = self.frame
        let cornerRadiusValue = CGFloat(10)
        
        // mainImageView
        mainImageView.setDimensions(height: frame.height * 0.75,
                                    width: frame.width)
        mainImageView.anchor(top: self.topAnchor,
                             left: self.leftAnchor,
                             right: self.rightAnchor,
                             paddingTop: 3,
                             paddingLeft: 3,
                             paddingRight: 3)
        
        
        // cornerRadius
        mainImageView.layer.cornerRadius = cornerRadiusValue
        view.layer.cornerRadius = cornerRadiusValue
        
        
        
        // lectureTitle
        lectureTitle.font = UIFont.appBoldFontWith(size: 16)
        lectureTitle.setDimensions(height: 17,
                                   width: contentView.frame.width * 0.7)
        lectureTitle.anchor(top: mainImageView.bottomAnchor,
                            left: mainImageView.leftAnchor,
                            paddingTop: 10)
        
        // tagLabel
        tagLabel.layer.cornerRadius = 15
//        tagLabel.setDimensions(height: 20, width: 40)
        tagLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tagLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
        tagLabel.anchor(top: lectureTitle.bottomAnchor,
                        left: mainImageView.leftAnchor,
                        bottom: contentView.bottomAnchor,
                        paddingTop: 5,
                        paddingBottom: 10)
        
        // rating
        rating.setDimensions(height: teachername.frame.height,
                             width: 25)
        rating.anchor(bottom: tagLabel.bottomAnchor,
                      right: mainImageView.rightAnchor)
        
        // starImage
        starImage.setDimensions(height: 12,
                                width: 12)
        starImage.centerY(inView: rating)
        starImage.anchor(right: rating.leftAnchor,
                         paddingRight: 0)
        
        
        // teachername
        teachername.font = UIFont.appRegularFontWith(size: 12)
        teachername.setDimensions(height: lectureTitle.frame.height - 2,
                                  width: 100)
        teachername.centerY(inView: rating)
        teachername.anchor(right: starImage.leftAnchor,
                           paddingRight: 10)
        
    }
}
