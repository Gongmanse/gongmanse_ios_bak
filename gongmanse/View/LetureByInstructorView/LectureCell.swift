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
    @IBOutlet weak var unitLabel: UILabel!           // 단위
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    
    func setSeriesCellData(_ type: SeriesDetailDataModel) {
        mainImageView.setImageUrl("\(fileBaseURL)/\(type.sThumbnail ?? "")")
//        mainImageView.layer.contentsRect = CGRect(x: 0.0, y: -0.1, width: 1.0, height: 1.0)
//        mainImageView.contentMode = .scaleAspectFill
        lectureTitle.text = type.sTitle
        teachername.text = "\(type.sTeacher!) 선생님"
        tagLabel.text = type.sSubject
        tagLabel.adjustsFontSizeToFitWidth = true
        tagLabel.backgroundColor = UIColor(hex: type.sSubjectColor ?? "000000")
        
        if (type.sUnit ?? "").isEmpty {
            unitLabel.isHidden = true
        } else {
            unitLabel.isHidden = false
            unitLabel.text = type.sUnit!
            
            if type.sUnit! == "용어" {
                unitLabel.backgroundColor = UIColor(hex: "fb6225")
            } else {
                unitLabel.backgroundColor = UIColor(hex: "008dc1")
            }
        }
    }
    
    func setVideoCellData(_ type: RelationSeriesDataModel) {
        mainImageView.setImageUrl("\(fileBaseURL)/\(type.sThumbnail)")
//        mainImageView.layer.contentsRect = CGRect(x: 0.0, y: -0.1, width: 1.0, height: 1.0)
//        mainImageView.contentMode = .scaleAspectFill
        lectureTitle.text = type.sTitle
        teachername.text = "\(type.sTeacher) 선생님"
        tagLabel.text = type.sSubject
        tagLabel.backgroundColor = UIColor(hex: type.sSubjectColor)
        
        if type.sUnit.isEmpty {
            unitLabel.isHidden = true
        } else {
            unitLabel.isHidden = false
            unitLabel.text = type.sUnit
            
            if type.sUnit == "용어" {
                unitLabel.backgroundColor = UIColor(hex: "fb6225")
            } else {
                unitLabel.backgroundColor = UIColor(hex: "008dc1")
            }
        }
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        let cornerRadiusValue = CGFloat(10)
        
        // mainImageView
        //0707 - edited by hp
        mainImageView.setDimensions(height: (UIScreen.main.bounds.width - 50) / 16 * 9,
                                    width: (UIScreen.main.bounds.width - 50))
        mainImageView.anchor(top: self.topAnchor,
                             left: self.leftAnchor,
                             right: self.rightAnchor,
                             paddingTop: 0,
                             paddingLeft: 0,
                             paddingRight: 0)
        
        
        // cornerRadius
        mainImageView.layer.cornerRadius = cornerRadiusValue
        view.layer.cornerRadius = cornerRadiusValue
        
        
        
        // lectureTitle
        lectureTitle.font = UIFont.appBoldFontWith(size: 16)
        lectureTitle.setDimensions(height: 17,
                                   width: UIScreen.main.bounds.width - 50)
        lectureTitle.anchor(top: mainImageView.bottomAnchor,
                            left: mainImageView.leftAnchor,
                            right: mainImageView.rightAnchor,
                            paddingTop: 10,
                            paddingLeft: 0,
                            paddingRight: 0)
        
        // tagLabel
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 10
//        tagLabel.setDimensions(height: 20, width: 56)
        tagLabel.setHeight(20)
//        tagLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        tagLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        tagLabel.anchor(top: lectureTitle.bottomAnchor,
                        left: mainImageView.leftAnchor,
                        bottom: contentView.bottomAnchor,
                        paddingTop: 5,
                        paddingBottom: 10)
        
        // unitLabel
        unitLabel.clipsToBounds = true
        unitLabel.layer.cornerRadius = 10
//        unitLabel.setDimensions(height: 20, width: 46)
        unitLabel.setHeight(20)
        unitLabel.centerY(inView: tagLabel)
        unitLabel.anchor(left: tagLabel.rightAnchor,
                           paddingLeft: 10)
        
        // rating
        /*rating.setDimensions(height: teachername.frame.height,
                             width: 25)
        rating.anchor(bottom: tagLabel.bottomAnchor,
                      right: mainImageView.rightAnchor)
        
        // starImage
        starImage.setDimensions(height: 12,
                                width: 12)
        starImage.centerY(inView: rating)
        starImage.anchor(right: rating.leftAnchor,
                         paddingRight: 0)*/
        rating.isHidden = true
        starImage.isHidden = true
        
        // teachername
        teachername.font = UIFont.appRegularFontWith(size: 12)
//        teachername.setDimensions(height: lectureTitle.frame.height - 2,
//                                  width: 100)
        teachername.centerY(inView: tagLabel)
        teachername.anchor(right: lectureTitle.rightAnchor,
                           paddingRight: 0)
        
    }
}
