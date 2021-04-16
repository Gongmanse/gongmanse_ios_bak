//
//  PaddingLabel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/16.
//

import UIKit

/* *
 Label inset 넣기 ( 위, 아래 양옆 여백 넣을 수 있음 )
 
 예시) @IBOutlet weak var labelName: PaddingLabel!
 
 labelName.topInset = 4
 labelName.bottomInset = 4
 labelName.leftInset = 6
 labelName.rightInset = 6
 
*/

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 0.0
    var bottomInset: CGFloat = 0.0
    var leftInset: CGFloat = 0.0
    var rightInset: CGFloat = 0.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
}
