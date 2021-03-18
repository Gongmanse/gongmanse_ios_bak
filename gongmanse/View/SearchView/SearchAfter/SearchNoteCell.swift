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
    @IBOutlet weak var word: UILabel!
    
    
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
            
            word.clipsToBounds = true
            word.backgroundColor = .mainOrange
            word.layer.cornerRadius = 10
            
            chemistry.clipsToBounds = true
            chemistry.layer.cornerRadius = 10
            titleImage.layer.cornerRadius = 15  
        }

}
