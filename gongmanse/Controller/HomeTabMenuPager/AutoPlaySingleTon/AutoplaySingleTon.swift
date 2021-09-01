//
//  AutoplaySingleTon.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/14.
//

import Foundation

// 06.16 당시 리팩토링할 시간적 여유가 없어서 만들고 사용하지 않음
// AutoPlayDataManager 의 currentViewtitleview 가능하면 enum으로 리팩토링할 것
//enum currentViewTitleView {
//    case series
//    case mainSubject
//    case science
//    case social
//    case others
//}


class AutoplayDataManager {
    
    static let shared = AutoplayDataManager()
    
    private init() { }
    
    /// 어떤 탭에서 클릭했는지 저장하는 프로퍼티
    var currentViewTitleView: String = ""
    
    // 탭에서 선택한 필터링을 저장하는 프로퍼티
    var currentFiltering: String = "" //전체보기, 문제풀이
    var currentSort: Int = 0 // 0최신순, 1평점순, 2이름순, 3과목순
    
    var currentSubjectNumber: Int = 0 //검색에서만 이용
    var currentGrade: String = "" //검색에서만 이용
    var currentKeyword: String = "" //검색에서만 이용
    
    var isAutoPlay: Bool = false
    var videoDataList: [VideoModels] = [] //최근목록,즐겨찾기,국영수,과학,사회,기타,진도,검색 중 자동재생일떄, 아니면 아래로
    var videoSeriesDataList: [PlayListData] = [] //추천,인기,강사별강의와
    var currentIndex: Int = 0 //목록에서 눌린 동영상index, 추천과 인기는 -1 이때는 시리즈에서 해당 동영상을 찾아야 한다.
    var currentJindoId: String = "" //진도학습에서 이용
}
