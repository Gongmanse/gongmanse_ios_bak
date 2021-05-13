//
//  NoteImageCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/12.
//

import UIKit

class NoteImageCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
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
        self.addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = .green
    }
    
}
