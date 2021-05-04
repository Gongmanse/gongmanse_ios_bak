//
//  NSAttributeString.swift
//  gongmanse
//
//  Created by wallter on 2021/05/04.
//

import UIKit

protocol NSAttributedStringColor: class {
    func convertStringColor(_ mainString: String, _ subString: String) -> NSAttributedString
}
