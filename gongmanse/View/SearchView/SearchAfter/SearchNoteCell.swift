//
//  SearchNoteCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import UIKit

class SearchNoteCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var chemistry: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    
    
    //MARK: - IBOutlet

    
    
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
            
            chemistry.clipsToBounds = true
            chemistry.layer.cornerRadius = 10
            chemistry.adjustsFontSizeToFitWidth = true
            
            titleImage.layer.cornerRadius = 15
            titleImage.contentMode = .scaleAspectFill
            titleImage.layer.borderWidth = 1
            titleImage.layer.borderColor = UIColor.lightGray.cgColor
            
            // 이미지 내부 % 비율로 조절 
            titleImage.layer.contentsRect = CGRect(x: -0.1, y: 0.0, width: 0.7, height: 0.7)
        }

}
