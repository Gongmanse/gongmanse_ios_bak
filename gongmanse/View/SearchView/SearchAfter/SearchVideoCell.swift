//
//  SearchVideoCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

class SearchVideoCell: UICollectionViewCell {

    //MARK: - Properties
    
    //MARK: - Outlet
    
    // TODO: word랑 Chemistry 추후에 삭제하고 collectionView로 구현
    @IBOutlet weak var chemistry: UILabel!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var rating: UILabel!
    
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
            
            
            videoImage.layer.cornerRadius = 15
            videoImage.contentMode = .scaleAspectFill
            
        }

}
