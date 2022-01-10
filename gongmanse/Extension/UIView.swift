//
//  UIView.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/17.
//

import UIKit

enum AIEdge:Int {
    case
    Top,
    Left,
    Bottom,
    Right,
    Top_Left,
    Top_Right,
    Bottom_Left,
    Bottom_Right,
    All,
    None
}

extension UIView {
    
    /* Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func applyShadowWithCornerRadius(color:UIColor, opacity:Float, radius: CGFloat, edge:AIEdge, shadowSpace:CGFloat)    {

            var sizeOffset:CGSize = CGSize.zero
            switch edge {
            case .Top:
                sizeOffset = CGSize(width: 0, height: -shadowSpace)
            case .Left:
                sizeOffset = CGSize(width: -shadowSpace, height: 0)
            case .Bottom:
                sizeOffset = CGSize(width: 0, height: shadowSpace)
            case .Right:
                sizeOffset = CGSize(width: shadowSpace, height: 0)


            case .Top_Left:
                sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace)
            case .Top_Right:
                sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace)
            case .Bottom_Left:
                sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace)
            case .Bottom_Right:
                sizeOffset = CGSize(width: shadowSpace, height: shadowSpace)


            case .All:
                sizeOffset = CGSize(width: 0, height: 0)
            case .None:
                sizeOffset = CGSize.zero
            }

            self.layer.cornerRadius = self.frame.size.height / 2
            self.layer.masksToBounds = true;

            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = sizeOffset
            self.layer.shadowRadius = radius
            self.layer.masksToBounds = false

            self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.layer.cornerRadius).cgPath
        }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension UITabBar {
    // Workaround for iOS 11's new UITabBar behavior where on iPad, the UITabBar inside
    // the Master view controller shows the UITabBarItem icon next to the text
    override open var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UITraitCollection(horizontalSizeClass: .compact)
        }
        return super.traitCollection
    }
}
