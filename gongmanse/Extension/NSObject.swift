//
//  NSObject.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/05.
//
import Foundation

// cell Register 를 편리하게 해주는 연산프로퍼티
extension NSObject {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
