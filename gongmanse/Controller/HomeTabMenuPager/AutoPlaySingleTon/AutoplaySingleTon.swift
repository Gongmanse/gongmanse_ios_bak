//
//  AutoplaySingleTon.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/14.
//

import Foundation

class AutoplayDataManager {
    
    static let shared = AutoplayDataManager()
    
    private init() { }
    
    var currentViewTitleView: String = ""
    var currentFiltering: String = ""
    
    // TODO: 자동재생 여부를 판단하는 Boolean
    // 1: 국영수
    var isAutoplayMainSubject: Bool = false
    
    // 2: 과학
    var isAutoplayScience: Bool = false
    
    // 3: 사회
    var isAutoplaySocialStudy: Bool = false
    
    // 4: 기타
    var isAutoplayOtherSubjects: Bool = false
    
    // 추천에서 접속했는지 판단하기 위한 Boolean -> 영상화면에서 재생목록 URL 선택시 사용됨.
    var isRecommandTab: Bool = false
    
    // 인기에서 접속했는지 판단하기 위한 Boolean -> 영상화면에서 재생목록 URL 선택시 사용됨.
    var isPopularTab: Bool = false
    
    // TODO: 자동재생이 켜졌을 때, 데이터 -> "BottomPlaylistCell" 에 이미 구현됨.
    // 그렇지만, 현재 보고있는 데이터위치를 확인하기 위해서 여기에 데이터를 받아야할 것 같음.
    // 추후에 개선된 방법이 떠오르면 삭제할 예정
    // 추천의 경우 "receiveRecommendModelData"
    
    /* 아래 경우는 모두 자동재생이 켜진 상태에서 호출할 데이터입니다. */
    /// "추천"에 있는 데이터 20 개
    var videoDataInRecommandTab: VideoInput?
    
    /// "인기"에 있는 데이터 20 개
    var videoDataInPopularTab: VideoInput?
    
    /// "국영수"에 있는 데이터 20 개
    var videoDataInMainSubjectsTab: VideoInput?
    
    /// "국영수" + "문제풀이" 에 있는 데이터 20 개
    var videoDataInMainSubjectsProblemSolvingTab: FilterVideoModels?
    
    /// "과학"에 있는 데이터 20 개
    var videoDataInScienceTab: VideoInput?
    
    /// "사회"에 있는 데이터 20 개
    var videoDataInSocialStudyTab: VideoInput?
    
    /// "기타"에 있는 데이터 20 개
    var videoDataInOtherSubjectsTab: VideoInput?
}
