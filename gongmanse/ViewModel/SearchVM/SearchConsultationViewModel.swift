//
//  SearchConsultationViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchConsultationViewModel {
    
    
    var responseDataModel: SearchConsultationModel? = nil
    
    func requestConsultationApi(keyword: String, sortId: String) {
        
        let postModel = SearchConsultationPostModel(keyword: keyword, sortID: sortId)
        
        let apiModel = SearchAfterConsultationAPIManager()
        apiModel.fetchConsultaionAPI(postModel) { [weak self] response in
            switch response{
            case .success(let data):
                self?.responseDataModel = data
                print(data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
