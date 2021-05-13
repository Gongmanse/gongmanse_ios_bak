//
//  PopularKeywordViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//

import Foundation
import Alamofire

class PopularKeywordViewModel {
    
    var delegate: TableReloadData?
    
    var popularKeywoard: PopularKeywordModel? = nil
    
    func requestKeywordData() {
        let popularManager = PopularAPIManager()
        popularManager.fetchPopularAPI { [weak self] result in
            switch result {
            case .success(let data):
                self?.popularKeywoard = data
                self?.delegate?.reloadTable()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

