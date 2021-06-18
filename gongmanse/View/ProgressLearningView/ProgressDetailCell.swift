//
//  ProgressDetailCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/09.
//

import UIKit

class ProgressDetailCell: UICollectionViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var lessonImage: UIImageView!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var teathername: UILabel!
    @IBOutlet weak var lessonRating: UILabel!
    
    @IBOutlet weak var subjectFirst: UILabel!
    @IBOutlet weak var subjectSecond: UILabel!
    @IBOutlet weak var starRating: UILabel!
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
        self.isUserInteractionEnabled = true
       // initialize what is needed
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lessonImage.layer.cornerRadius = 15
        lessonImage.layer.contentsRect = CGRect(x: 0, y: -0.15, width: 1, height: 1)
        
        lessonTitle.font = .appBoldFontWith(size: 15)
        starRating.font = .appBoldFontWith(size: 13)
        teathername.font = .appBoldFontWith(size: 13)
        
        subjectFirst.font = .appBoldFontWith(size: 12)
        subjectFirst.textColor = .white
        subjectFirst.textAlignment = .center
        subjectFirst.clipsToBounds = true
        subjectFirst.layer.cornerRadius = subjectFirst.frame.size.height / 2
        
        
        subjectSecond.font = .appBoldFontWith(size: 12)
        subjectSecond.textColor = .white
        subjectSecond.textAlignment = .center
        subjectSecond.clipsToBounds = true
        subjectSecond.layer.cornerRadius = subjectSecond.frame.size.height / 2
        
        
    }
}
