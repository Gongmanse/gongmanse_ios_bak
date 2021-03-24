//
//  UIColor.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/09.
//

import UIKit

extension UIColor {
    
    // 공통색상
    
    static let mainOrange = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
    static let progressBackgroundColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
    
    
    // rgb 바로 넣을 수 있는 메소드
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    
    
    
}



extension UIView {
    
    // 그림자효과 커스텀메소드
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        layer.shadowRadius = CGFloat(2)
        layer.masksToBounds = false
    }
}
