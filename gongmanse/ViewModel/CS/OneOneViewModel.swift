//
//  OneOneViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation

protocol PopDelgate: class {
    func popViewController()
}

protocol EnquiryListState: class {
    var canEnquiryList: Bool { get set }
}

class OneOneViewModel {
    
    
    var oneOneList: OneOneQnAList?
    
    weak var delegateTable: TableReloadData?
    weak var delegatePop: PopDelgate?
    weak var delegateState: EnquiryListState?
    
    /// 1:1 목록
    func reqiestOneOneList(completionHandler: @escaping () -> Void) {
        
        OneOneAPIManager.fetchOneOneListApi { response in
            switch response {
            case .success(let data):
                
                self.oneOneList = data
                self.delegateState?.canEnquiryList = data.data.count != 0 ? true : false
                self.delegateTable?.reloadTable()
                completionHandler()
            case .failure(let err):
                self.delegateState?.canEnquiryList = false
                completionHandler()
                print("reqiestOneOneList, Failure: \n", err.localizedDescription)
            }
        }
    }
    
    /// 1:1 등록
    func requestOneOneRegist(question: String, type: Int, comepletionHandler: @escaping () -> Void) {
        
        
        let parameter = OneOneQnARegist(token: Constant.token, question: question, type: "\(type)")
        
        OneOneAPIManager.fetchOneOneRegistApi(parameter) {
            print("requestOneOneRegist == ")
            comepletionHandler()
        }
    }
    
    /// 1:1 삭제
    func requestOneOneDelete(id: String) {
        
        let parameter = OneOneQnADelete(id: id)
        
        OneOneAPIManager.fetchOneOneDeleteApi(parameter) {
            self.delegatePop?.popViewController()
            print("requestOneOneDelete == ")
        }
    }
    
}
