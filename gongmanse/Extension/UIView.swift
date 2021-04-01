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

