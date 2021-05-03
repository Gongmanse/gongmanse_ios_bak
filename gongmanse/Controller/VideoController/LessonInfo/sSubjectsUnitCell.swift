//
//  sSubjectsUnitCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/03.
//

import UIKit

class sSubjectsUnitCell: UICollectionViewCell {
 
    //MARK: - Properties

    let sSubjectsUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "asdfasdfasdfasdf"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        configure()
        self.backgroundColor = .green
        self.layer.cornerRadius = 7.5
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
    
    
    func configure() {
        
        self.addSubview(sSubjectsUnitLabel)
        sSubjectsUnitLabel.setDimensions(height: 40, width: 100)
        sSubjectsUnitLabel.centerX(inView: self)
        sSubjectsUnitLabel.centerY(inView: self)
    }
    
}
