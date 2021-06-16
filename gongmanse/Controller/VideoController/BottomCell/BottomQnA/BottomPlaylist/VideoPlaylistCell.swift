//
//  VideoPlaylistCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import UIKit

class VideoPlaylistCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // initialize what is needed
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isUserInteractionEnabled = true
        // initialize what is needed
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
    }
    
    func setupLayout() {
        self.backgroundColor = .white
    }
}
