//
//  TeacherPlaylistCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

class TeacherPlaylistCell: UICollectionViewCell {

    //MARK: - Properties
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var mainImageView: UIImageView!  // 강의 미리보기 이미지
    @IBOutlet weak var view: UIView!                // cell 전체 뷰
    @IBOutlet weak var overlayView: UIView!         // 강의 수 뷰
    @IBOutlet weak var bottomView: UIView!          // 하단 뷰
    @IBOutlet weak var lectureTitle: UILabel!       // 강의명
    @IBOutlet weak var teachername: UILabel!        // 선생명
    @IBOutlet weak var tagLabel: UILabel!           // 태그명
    @IBOutlet weak var numberOfLecture: UILabel!
    
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func setCell(_ data: LectureSeriesDataModel) {
        mainImageView.setImageUrl("\(fileBaseURL)/\(data.sThumbnail ?? "")")
        lectureTitle.text = data.sTitle
        numberOfLecture.text = data.iCount
        teachername.text = "\(data.sTeacher!) 선생님"
        tagLabel.text = data.sSubject
        tagLabel.backgroundColor = UIColor(hex: "\(data.sSubjectColor ?? "000000")") 
    }
    
    // MARK: - Helper functions
    
    func configureUI() {
        
        let cornerRadiusValue = CGFloat(10)
        
        // mainImageView
        //0707 - edited by hp
        mainImageView.setDimensions(height: (UIScreen.main.bounds.width - 50) / 16 * 9,
                                    width: UIScreen.main.bounds.width - 50)
        
        mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        
//        mainImageView.addShadow()
        
        // cornerRadius
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.layer.cornerRadius = cornerRadiusValue
        
        view.layer.cornerRadius = cornerRadiusValue
        
        overlayView.layer.masksToBounds = true
        overlayView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        overlayView.layer.cornerRadius = cornerRadiusValue
        
        
        // overlayView
        overlayView.anchor(top: mainImageView.topAnchor,
                           left: mainImageView.leftAnchor,
                           bottom: mainImageView.bottomAnchor,
                           width: mainImageView.frame.width * 0.337)
        
        // numberOfLecture

        numberOfLecture.translatesAutoresizingMaskIntoConstraints = false
        numberOfLecture.heightAnchor.constraint(equalToConstant: 20).isActive = true
        numberOfLecture.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        
        numberOfLecture.centerX(inView: overlayView)
        numberOfLecture.centerY(inView: overlayView)
        numberOfLecture.font = UIFont.appBoldFontWith(size: 18)
        
        // bottomView
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        
        // lectureTitle
        lectureTitle.font = UIFont.appBoldFontWith(size: 16)
        lectureTitle.setDimensions(height: 17,
                                   width: bottomView.frame.width - 6)
        lectureTitle.anchor(top: bottomView.topAnchor,
                            left: bottomView.leftAnchor,
                            right: bottomView.rightAnchor,
                            paddingTop: 10,
                            paddingLeft: 0,
                            paddingRight: 0)
        
        // teachername
        teachername.font = UIFont.appRegularFontWith(size: 12)
//        teachername.setDimensions(height: lectureTitle.frame.height - 2,
//                                  width: 100)
//        teachername.anchor(top: lectureTitle.bottomAnchor,
//                           left: lectureTitle.leftAnchor,
//                           paddingTop: 5,
//                           paddingLeft: 3)
        teachername.centerY(inView: tagLabel)
        teachername.anchor(right: lectureTitle.rightAnchor,
                           paddingRight: 0)
        
        // tag Label
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 10
        tagLabel.font = UIFont.appBoldFontWith(size: 12)
        
//        tagLabel.centerY(inView: lectureTitle)
//        tagLabel.anchor(right: bottomView.rightAnchor,
//                        paddingRight: 5)
//        tagLabel.setDimensions(height: 20,
//                                  width: 56)
        tagLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tagLabel.anchor(top: lectureTitle.bottomAnchor,
                           left: lectureTitle.leftAnchor,
                           paddingTop: 5,
                           paddingLeft: 0)
//        tagLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 90).isActive = true
//        tagLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 30).isActive = true
        
    }

}
