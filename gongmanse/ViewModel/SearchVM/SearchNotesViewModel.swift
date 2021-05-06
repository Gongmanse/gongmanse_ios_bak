//
//  SearchNotesViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchNotesViewModel: NSAttributedStringColor {
    
    weak var reloadDelegate: CollectionReloadData?
    
    var searchNotesDataModel: SearchNotesModel? = nil
    
    func reqeustNotesApi(subject: String, grade: String, keyword: String, offset: String, sortID: String) {
        
        let postModel = SearchNotesPostModel(subject: subject,
                                             grade: grade,
                                             keyword: keyword,
                                             offset: offset,
                                             sortID: sortID)
        
        let notesAPI = SearchAfterNotesAPIManager()
        notesAPI.fetchNotesAPI(postModel) { response in
            switch response {
            case .success(let data):
                self.searchNotesDataModel = data
                self.reloadDelegate?.reloadCollection()
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
    
}
