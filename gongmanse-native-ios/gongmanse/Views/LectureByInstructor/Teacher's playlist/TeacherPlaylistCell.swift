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
        mainImageView.addShadow()
        
        // cornerRadius
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
        numberOfLecture.setDimensions(height: 20, width: 25)
        numberOfLecture.centerX(inView: overlayView)
        numberOfLecture.centerY(inView: overlayView)
        numberOfLecture.font = UIFont.appBoldFontWith(size: 18)
        
        // bottomView
        bottomView.setDimensions(height: frame.height * 0.25,
                                 width: frame.width)
        bottomView.centerX(inView: self)
        bottomView.anchor(top: mainImageView.bottomAnchor,
                          bottom: self.bottomAnchor)
        
        // lectureTitle
        lectureTitle.font = UIFont.appBoldFontWith(size: 16)
        lectureTitle.setDimensions(height: 17,
                                   width: bottomView.frame.width * 0.7)
        lectureTitle.anchor(top: bottomView.topAnchor,
                            left: bottomView.leftAnchor,
                            paddingTop: 10,
                            paddingLeft: 3)
        
        // teachername
        teachername.font = UIFont.appRegularFontWith(size: 12)
        teachername.setDimensions(height: lectureTitle.frame.height - 2,
                                  width: 100)
        teachername.anchor(top: lectureTitle.bottomAnchor,
                           left: lectureTitle.leftAnchor,
                           paddingTop: 5,
                           paddingLeft: 3)
        
        // tag Label
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 10
        tagLabel.font = UIFont.appBoldFontWith(size: 12)
        tagLabel.setDimensions(height: lectureTitle.frame.height,
                               width: 40)
        tagLabel.centerY(inView: lectureTitle)
        tagLabel.anchor(right: bottomView.rightAnchor,
                        paddingRight: 5)
        
        
    }

}
