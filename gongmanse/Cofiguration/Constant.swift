//
//  Constant.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import Alamofire

struct Constant {
    static let BASE_URL = "https://api.gongmanse.com"
//    static let GONGMANSE_BASE_URL = ""
    
    static var token: String = ""
    static var jwtToken: String = ""
    
    // 화면 크기
    static let bounds = UIScreen.main.bounds
    static let width = bounds.width
    static let height = bounds.height
    
    static let termOfServiceText =
        """
        공만세 서비스 이용약관
                
        -제 1장 총 칙-

        제 1조 (목적)

        이 약관은 공만세(이하 '회사')의 웹사이트"공만
        세" 또는 스마트폰 등 이동통신기기를 통해 제공
        되는 "공만세" 모바일 어플리케이션을 통해 회사
        가 운영, 제공하는 인터넷 관련 서비스 (이하 "공
        만세 서비스" 또는 "서비스")을 이용함에 있어 이
        용자의 권리, 의무 및 책임사항을 규정함을 목적
        으로 합니다.
        """
    
}
