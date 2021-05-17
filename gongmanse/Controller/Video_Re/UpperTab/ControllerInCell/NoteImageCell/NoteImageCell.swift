//
//  NoteImageCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/12.
//

import UIKit

class NoteImageCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var url: String? {
        didSet {
//            noteImageView.sd_setImage(with: URL(string: url ?? ""))
//            noteImageView.sizeToFit()
        }
    }
    
    public var noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .topLeft
        return imageView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.addSubview(noteImageView)
        noteImageView.anchor(top: self.topAnchor,
                             left: self.leftAnchor,
                             bottom: self.bottomAnchor,
                             right: self.rightAnchor)
        noteImageView.backgroundColor = .gray
    }
    

}
