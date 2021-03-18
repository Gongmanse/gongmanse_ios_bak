//
//  SearchConsultCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import UIKit

class SearchConsultCell: UICollectionViewCell {

    //MARK: - Properties
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var writer: UILabel!
    @IBOutlet weak var writtenDate: UILabel!
    @IBOutlet weak var state: UILabel!
    
    //MARK: - Lifecycle
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
     
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.isUserInteractionEnabled = true
        }
     
        override func awakeFromNib() {
            super.awakeFromNib()
            titleImage.layer.cornerRadius = 10
            profileImage.layer.cornerRadius = profileImage.frame.width * 0.5 
            state.clipsToBounds = true
            state.layer.cornerRadius = 8
        }

}
