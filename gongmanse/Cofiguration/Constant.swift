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
    
    static let BASE_URL = "https://api.gongmanse.com"
//    static let GONGMANSE_BASE_URL = ""
    
    static var userID: String = ""
    static var token: String = "ZWE1NmYyNzE5NTIwZjU3Nzg5MjZmZGZkZjIxNGYzNTMxOGMyNzZhMTgxYjE3NGJhYjVjNmJkN2M5YTcwOTRmNDhmZTFiMGFkOTcyNDUwNzhjOGE0NzZmMDM3NGNhODM1OThhMDM0MDNmNjM1MjUxMzQzMzE4YTFmMDk0ZDRiOWNBNDMyclBSSGdCUy9iaDIwRW9jVXZWT2RZRUNlZjJmdEVFeVBJRUtQcTFHQlU2Wncvbmg5V2pqQmdsNjJ2cUhYS1BBaEJYcTBpUkFuU0tucnlzd0lxdz09"
    static var jwtToken: String = ""
    static var dtPremiumActivate: String = ""
    static var dtPremiumExpire: String = ""
    
    
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
