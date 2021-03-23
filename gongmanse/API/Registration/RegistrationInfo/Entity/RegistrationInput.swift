//
//  RegistrationInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//
//  https://api.gongmanse.com/v1/members (post)

struct RegistrationInput: Codable {
    // body
    var username: String            // woosung
    var password: String            // 12341234
    var confirm_password: String     // 12341234
    var first_name: String           // woosung
    var middle_name: String?
    var last_name: String?
    var name_suffix: String?
    var nickname: String            // woosung
    var gender: String?
    var phone_number: Int            // 01047850519
    var verification_code: Int       // (자신의 폰으로 받아야하는 숫자) 431212 - 일정시간 지나면 다시 발급받아야함.
    var email: String               // woosung@test.com
    var address1: String            // 45 gasnaro
    var address2: String            // #45
    var city: String                // jeju
    var state: String?
    var zip: Int?                    // 필수값 아님.
    var country: String             // Korea
}
