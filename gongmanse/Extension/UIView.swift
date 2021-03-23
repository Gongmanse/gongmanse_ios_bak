//
//  UIView.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/17.
//

import UIKit

extension UIView {
    
    /* Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}


extension UIButton {

  /// Sets the background color to use for the specified button state.
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {

    let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)

    UIGraphicsBeginImageContext(minimumSize)

    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(origin: .zero, size: minimumSize))
    }

    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    self.clipsToBounds = true
    self.setBackgroundImage(colorImage, for: forState)
  }
}

extension UIButton {

    func setBackgroundColor2(color: UIColor, forState: UIControl.State) {

       UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
       UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
       UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
       let colorImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()


       self.setBackgroundImage(colorImage, for: forState)
   }
}
