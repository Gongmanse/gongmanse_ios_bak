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
    var recentKeywordList: RecentKeywordModel?
    
    func requestGetListApi() {
        
        let recentApi = RecentKeywordAPIManager()
        recentApi.fetchRecentKeywordListApi { response in
            switch response {
            case .success(let data):
                print(data)
                self.recentKeywordList = data
                self.reloadDelegate?.reloadTable()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
