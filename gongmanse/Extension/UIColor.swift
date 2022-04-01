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
    
    // 노트필기 색상
    static let redPenColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
    static let greenPenColor = #colorLiteral(red: 0.2518872917, green: 0.6477053165, blue: 0.3158096969, alpha: 1)
    static let bluePenColor = #colorLiteral(red: 0.07627140731, green: 0.6886936426, blue: 0.6746042967, alpha: 1)
    static let eraserColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    
    // 1:1문의
    static let gray200Color = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    
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

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
