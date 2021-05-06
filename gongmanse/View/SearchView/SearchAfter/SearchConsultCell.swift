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
    @IBOutlet weak var stateLabel: UILabel!
    
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
        titleImage.contentMode = .scaleAspectFill
        
        profileImage.layer.cornerRadius = profileImage.frame.width * 0.5
        profileImage.contentMode = .scaleAspectFit
        
        stateLabel.clipsToBounds = true
        stateLabel.layer.cornerRadius = 8
    }
    
    
    func labelState(_ state: Bool) {
        
        if state {
            stateLabel.backgroundColor = .mainOrange
            stateLabel.text = "답변 완료>"
            stateLabel.textColor = .white
        } else {
            stateLabel.backgroundColor = .lightGray
            stateLabel.text = "대기 중>"
            stateLabel.textColor = .white
        }
    }
}
