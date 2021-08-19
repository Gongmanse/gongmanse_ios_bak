//
//  String.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/24.
//

import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

// NSAttributeString 중간에 글자 색 바꾸기 

extension String {
    
    func convertStringColor(_ mainString: String, _ subString: String, _ color: UIColor) -> NSAttributedString{
        let range = (mainString as NSString).range(of: subString)
        
        let mutableString = NSMutableAttributedString.init(string: mainString)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        return mutableString
    }
}

extension String {
    
    // regex의 조건에 따라서 필터링한 값을 array<String>으로 리턴하는 메소드
    func getOnlyText(regex: String) -> [String] {
        do {
            // 입력받은 조건문을 표현식 객체에 넣는다.
            let regex = try NSRegularExpression(pattern: regex)
            // self. String의 시작부터 끝까지 정규표현식에 맞게 필터링한 후 "result" 객체에 할당한다.
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            // 각 array의 element를 String으로 캐스팅한다.
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("DEBUG: invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

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
        let passwordRegEx = "^.{8,16}$"
        
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
 
        
    func withCommas() -> String {
        let largeNumber = Int(self) ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber)) ?? "0"
        return formattedNumber
    }
    
    func withDouble() -> String {
        let value = Double(self) ?? 0.0
        return String(format: "%.1f", value)
    }
}
