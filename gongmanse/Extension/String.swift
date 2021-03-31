//
//  String.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/24.
//

import UIKit

extension String {
    
    // 이메일 정규식
    // @를 사용했는지 여부
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    
    
    func validate() -> Bool {
        let regEx = "[0-9]{6}"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        
        return predicate.evaluate(with: self)
    }

    
    func getCertificationNumber(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("DEBUG: invalid regex: \(error.localizedDescription)")
            return []
        }
        
    }
    
    
    // 패스워드 정규식
    // 8~16글자 + 대문자 한개 이상포함 + 소문자 + 숫자 조합 (한글X)
    func validatePassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,16}$"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    
    // 이름 정규식
    // 한글만 포함
    func validatName() -> Bool {
        let nameRegEx = "[가-힣]{1,}"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return predicate.evaluate(with: self)
    }
    
    // 휴대전화번호 정규식
    // 숫자만 추출
    func validatePhoneNumber() -> Bool {
        let numberRegEx = "^010-?([0-9]{4})-?([0-9]{4})"

        let predicate = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        return predicate.evaluate(with: self)
    }
 
        

    
    
}
