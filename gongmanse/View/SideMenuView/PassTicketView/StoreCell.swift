//
//  StoreCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/18.
//

import UIKit

class StoreCell: UICollectionViewCell {

    @IBOutlet weak var selectSubscribeButton: UIButton!
    var select = true
    
    let selectImage30 = "30DayTicketOn"
    let nonSelectImage30 = "30DayTicketOff"
    
    let selectImage90 = "90DayTicketOn"
    let nonSelectImage90 = "90DayTicketOff"
    
    let selectImage150 = "150DayTicketOn"
    let nonSelectImage150 = "150DayTicketOff"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func addSelect(_ sender: UIButton) {
        switch selectSubscribeButton.tag {
        case 0:
            
            sender.isSelected = !sender.isSelected
            
            switch sender.isSelected {
            case true:
                let images = UIImage(named: selectImage30)
                selectSubscribeButton.setImage(images, for: .normal)
            case false :
                let images = UIImage(named: nonSelectImage30)
                selectSubscribeButton.setImage(images, for: .normal)
            }
            
        case 1:
            
            sender.isSelected = !sender.isSelected
            
            switch sender.isSelected {
            case true:
                let images = UIImage(named: selectImage90)
                selectSubscribeButton.setImage(images, for: .normal)
            case false :
                let images = UIImage(named: nonSelectImage90)
                selectSubscribeButton.setImage(images, for: .normal)
            }
            
        case 2:
            
            sender.isSelected = !sender.isSelected
            
            switch sender.isSelected {
            case true:
                let images = UIImage(named: selectImage150)
                selectSubscribeButton.setImage(images, for: .normal)
            case false :
                let images = UIImage(named: nonSelectImage150)
                selectSubscribeButton.setImage(images, for: .normal)
            }
        default:
            return
        }
    }

}
