//
//  RecentKeywordViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import Foundation
import Alamofire

//struct RecentKeywordViewModel {
//    let date: String            // Data 메소드를 활용하여 오늘 날짜를 입력
//    let keyword: String         // 검색한 키워드를 생성
//    let indexPath: IndexPath    // 몇 번째 cell인지 indexPath를 넘김
//    
//}

class RecentKeywordViewModel {
    
    weak var reloadDelegate: TableReloadData?
//    var recentKeywordList: RecentKeywordModel?
    var recentList: [RecentKeywordDataModel] = []
    
    let requestRecentApi = RecentKeywordAPIManager()
    
    var isLoading = false
    
    // 최근 검색어 목록 불러오기
    func requestGetListApi(_ offset: Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        requestRecentApi.fetchRecentKeywordListApi(offset: offset) { response in
            self.isLoading = false
            switch response {
            case .success(let data):
                if offset == 0 {
                    self.recentList.removeAll()
                }
                self.recentList.append(contentsOf: data.data)
                self.reloadDelegate?.reloadTable()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // 최근 검색어 저장
    func requestSaveKeywordApi(_ word: String) {
        
        let postData = RecentKeywordSaveModel(token: Constant.token, words: word)
        
        requestRecentApi.fetchKeywordSaveApi(postData) { response in
            switch response {
            case .success(let data):
                print("DEBUG == Success save Keyword", data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // 최근 검색어 제거
    func requestDeleteKeywordApi(_ keywordID: String) {
        
        let postData = RecentKeywordDeleteModel(keywordID: keywordID, token: Constant.token)
        print(postData)
        requestRecentApi.fetchKeywordDeleteApi(postData) { response in
            switch response {
            case .success(_):
                self.reloadDelegate?.reloadTable()
                print("DEBUG == Success Delete Keyword")
            case .failure(let error):
                self.reloadDelegate?.reloadTable()
                print(error.localizedDescription)
            }
        }
    }
}
