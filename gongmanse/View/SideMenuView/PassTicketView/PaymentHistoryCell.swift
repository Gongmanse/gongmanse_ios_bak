//
//  PaymentHistoryCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/18.
//

import UIKit

class PaymentHistoryCell: UITableViewCell {

    // MARK: - Properties
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var passImage: UIImageView!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var paymentDate: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        let viewWidth = self.frame.width
        let viewHegiht = self.frame.height
        
        // passImage
        passImage.setDimensions(height: viewHegiht * 0.11,
                                width: viewHegiht * 0.11)
        passImage.anchor(top: self.topAnchor,
                         left: self.leftAnchor,
                         paddingTop: viewHegiht * 0.15,
                         paddingLeft: 20)
        
        titleLabel.font = UIFont.appBoldFontWith(size: 10)
        titleLabel.centerY(inView: passImage)
        titleLabel.anchor(left: passImage.rightAnchor,
                            paddingLeft: 2)
        
        
        // passLabel
        passLabel.font = UIFont.appEBFontWith(size: 18)
        passLabel.textColor = .mainOrange
        passLabel.setDimensions(height: viewHegiht * 0.22,
                                width: viewWidth * 0.4)
        passLabel.anchor(top: passImage.bottomAnchor,
                         left: passImage.leftAnchor,
                         paddingTop: viewHegiht * 0.07)
        
        paymentDate.font = UIFont.appBoldFontWith(size: 10)
        paymentDate.centerY(inView: passImage)
        paymentDate.setDimensions(height: passImage.frame.height,
                                  width: viewWidth * 0.6)
        paymentDate.anchor(right: self.rightAnchor,
                           paddingRight: 20)
        
        // price
        price.font = UIFont.appEBFontWith(size: 14)
        price.setDimensions(height: passLabel.frame.height * 0.9,
                            width: viewWidth * 0.4)
        price.anchor(bottom: passLabel.bottomAnchor,
                     right: self.rightAnchor,
                     paddingRight: 20)
    }
}
