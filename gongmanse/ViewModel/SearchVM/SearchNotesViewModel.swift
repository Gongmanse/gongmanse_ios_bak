//
//  SearchNotesViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchNotesViewModel {
    
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
    
}
