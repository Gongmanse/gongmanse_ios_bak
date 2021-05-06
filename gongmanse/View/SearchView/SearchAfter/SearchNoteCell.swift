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
            
            titleImage.layer.cornerRadius = 15
            titleImage.contentMode = .scaleAspectFill
            titleImage.layer.borderWidth = 1
            titleImage.layer.borderColor = UIColor.lightGray.cgColor
            
            videoButton.backgroundColor = .mainOrange
            videoButton.layer.cornerRadius = 10
            videoButton.setTitle("동영상 재생", for: .normal)
            videoButton.setTitleColor(.white, for: .normal)
        }

}
