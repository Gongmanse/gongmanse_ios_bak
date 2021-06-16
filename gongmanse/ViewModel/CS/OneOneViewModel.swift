//
//  OneOneViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation

class OneOneViewModel {
    
    
    var oneOneList: OneOneQnAList?
    
    weak var delegateTable: TableReloadData?
    
    /// 1:1 목록
    func reqiestOneOneList() {
        
        OneOneAPIManager.fetchOneOneListApi { response in
            switch response {
            case .success(let data):
                print(data)
                self.oneOneList = data
                self.delegateTable?.reloadTable()
            case .failure(let err):
                print("reqiestOneOneList, Failure: \n", err.localizedDescription)
            }
        }
    }
    
    /// 1:1 등록
    func requestOneOneRegist(question: String, type: String) {
        
        let parameter = OneOneQnARegist(token: Constant.token, question: question, type: type)
        
        OneOneAPIManager.fetchOneOneRegistApi(parameter) {
            print("requestOneOneRegist == ")
        }
    }
    
    /// 1:1 삭제
    func requestOneOneDelete(id: String) {
        
        let parameter = OneOneQnADelete(id: id)
        
        OneOneAPIManager.fetchOneOneDeleteApi(parameter) {
            print("requestOneOneDelete == ")
        }
    }
    
}
