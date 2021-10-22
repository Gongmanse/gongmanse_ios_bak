//
//  Constant.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import Alamofire

struct Constant {
    /* 필터 전역변수 */
    static var sortedIndex: SortedIndex = .rating
    static var category: Category = .all
    
    static let BASE_URL = apiBaseURL
//    static let GONGMANSE_BASE_URL = ""
    
    static var userID: String = ""
    static var token: String = ""
    static var refreshToken: String = "" {
        didSet {
            /**
             1. 앱이 실행되면 AppDelegate -> 이 프로퍼티로 현재 존재하는 refreshToken을 전달한다.
             2. didSet옵저버가 활성화되여 API연결을 한다.
             3-true. 성공하면 Constant.token에 token을 할당한다.
             3-false. 실패하면, 로그인을 token과 refreshToken 값을 비운다.
             */
            if refreshToken.count > 3 {
                LoginDataManager().getTokenByRefreshToken(RefreshTokenInput(grant_type: "refresh_token",
                                                                            refresh_token: Constant.refreshToken))
            }
            UserDefaults.standard.setValue(Constant.refreshToken, forKey: "refreshToken")
        }
    }
    static var dtPremiumActivate: String = ""

    static var dtPremiumExpire: String = ""
    
    static var remainPremiumDateInt: Int?
    
    var getRefreshToken: Void {
        LoginDataManager().getTokenByRefreshToken(RefreshTokenInput(grant_type: "refresh_token",
                                                                    refresh_token: Constant.refreshToken))
    }
    
    
    static var isGuestKey: Bool {
        return token.count < 10 ? true : false
    }
    
    static var isTicket: Bool {
        dtPremiumActivate.count > 3
    }
    
    static var isLogin: Bool {
        return Constant.token.count > 3
    }
    
    // 화면 크기
    static let bounds = UIScreen.main.bounds
    static let width = bounds.width
    static let height = bounds.height
    
    // 테스트용 임시 토큰값
    static let testToken = "ZTkzOGUwODkzMWYwY2JkOGQ3NjljZGZjYjIwODlhMzg5NjVmYjc2OGRjZDIyOTdkOTc5ODNiMTYzMjVlMDg0ZjY3Y2UxM2I2OTE4MTM2YTJmYjRlZWNhYmZkYTQwNWI3N2VhNmM4MmRjNmI1NWEzNzk5YjA1OTg5YzAzNDMzNjZwZHpNeW0wamdUb3lzeUtnbXhFUyszenhmNHp1ZThpN2Zmam56blNUc3NWWUMrOGJCTDVQa2V1ajhiMkgxdWo4MDJKem1tUGJ0dEx2ZVJlb0NsUmZndz09"
    
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

enum SortedIndex {
    case rating
    case latest
    case name
    case subject
    
    /// 정렬 필터링 인덱스
    /// - .rating: 평점순(기본값)
    /// - .latest: 최신순
    /// - .name: 이름순
    /// - .subject: 과목순
    var index: Int {
        let index: Int
        switch self {
        case .rating:
            index = 2
        case .latest:
            index = 3
        case .name:
            index = 1
        case .subject:
            index = 4
        }
        return index
    }
}

enum Category {
    case all
    case serise
    case quiz
    case note
    
    /// 카테고리 필터링 인덱스
    /// - .all: 전체 보기(기본값)
    /// - .serise: 시리즈 보기
    /// - .quiz: 문제 풀이
    /// - .note: 노트 보기
    var index: Int {
        let index: Int
        switch self {
        case .all:
            index = 0
        case .serise:
            index = 2
        case .quiz:
            index = 1
        case .note:
            index = 3
        }
        return index
    }
}

