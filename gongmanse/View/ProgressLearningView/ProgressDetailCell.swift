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
        
        // 임시로 넣은 그림자효과.
        lessonImage.layer.cornerRadius = 15
        lessonImage.addShadow()
    }
}
