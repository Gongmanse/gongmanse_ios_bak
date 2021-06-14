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
    
    // TODO: 자동재생 여부를 판단하는 Boolean
    // 1: 국영수
    var isAutoplayMainSubject: Bool = false
    
    // 2: 과학
    var isAutoplayScience: Bool = false
    
    // 3: 사회
    var isAutoplaySocialStudy: Bool = false
    
    // 4: 기타
    var isAutoplayOtherSubjects: Bool = false
    
    // TODO: 자동재생이 켜졌을 때, 데이터 -> "BottomPlaylistCell" 에 이미 구현됨.
    // 그렇지만, 현재 보고있는 데이터위치를 확인하기 위해서 여기에 데이터를 받아야할 것 같음.
    // 추후에 개선된 방법이 떠오르면 삭제할 예정
    // 추천의 경우 "receiveRecommendModelData"
    
    /// "추천"에 있는 데이터 20 개
    var videoDataInRecommandTab: VideoInput?
    
    /// "인기"에 있는 데이터 20 개
    var videoDataInPopularTab: VideoInput?
    
    /// "국영수"에 있는 데이터 20 개
    var videoDataInMainSubjectsTab: VideoInput?
    
    /// "과학"에 있는 데이터 20 개
    var videoDataInScienceTab: VideoInput?
    
    /// "사회"에 있는 데이터 20 개
    var videoDataInSocialStudyTab: VideoInput?
    
    /// "기타"에 있는 데이터 20 개
    var videoDataInOtherSubjectsTab: VideoInput?
}
