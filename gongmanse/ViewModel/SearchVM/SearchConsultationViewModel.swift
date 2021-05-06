//
//  SearchConsultationViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchConsultationViewModel: NSAttributedStringColor {
    
    weak var reloadDelegate: CollectionReloadData?
    
    var responseDataModel: SearchConsultationModel? = nil
    
    func requestConsultationApi(keyword: String, sortId: String) {
        
        let postModel = SearchConsultationPostModel(keyword: keyword, sortID: sortId)
        
        let apiModel = SearchAfterConsultationAPIManager()
        
        apiModel.fetchConsultaionAPI(postModel) { [weak self] response in
            switch response{
            case .success(let data):
                self?.responseDataModel = data
                self?.reloadDelegate?.reloadCollection()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func convertStringColor(_ mainString: String, _ subString: String) -> NSAttributedString{
        let range = (mainString as NSString).range(of: subString)
        
        let mutableString = NSMutableAttributedString.init(string: mainString)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainOrange, range: range)
        
        return mutableString
    }
    
    func answerState(state: String) -> Bool {
        return state == "1" ? true : false
    }
}
