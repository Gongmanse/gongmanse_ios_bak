//
//  RegistrationInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//
//  https://api.gongmanse.com/v1/members (post)

struct RegistrationInput: Encodable {
    // body
    var username: String            // woosung
    var password: String            // 12341234
    var confirmPassword: String     // 12341234
    var firstname: String           // woosung
    var middlename: String?
    var lastname: String?
    var nameSuffix: String?
    var nickname: String            // woosung
    var gender: String?
    var phoneNumber: Int            // 01047850519
    var verificationCode: Int       // (자신의 폰으로 받아야하는 숫자) 431212 - 일정시간 지나면 다시 발급받아야함.
    var email: String               // woosung@test.com
    var address1: String            // 45 gasnaro
    var address2: String            // #45
    var city: String                // jeju
    var state: String?
    var zip: Int                    // 431212
    var country: String             // Korea
}
