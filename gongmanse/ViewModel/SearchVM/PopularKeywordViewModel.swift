//
//  PopularKeywordViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//

import Foundation
import Alamofire

protocol PopularReloadData: class {
    func reloadData()
}

class PopularKeywordViewModel {
    
    var delegate: PopularReloadData?
    
    var popularKeywoard: PopularKeywordModel? = nil
    
    func requestKeywordData() {
        let popularManager = PopularAPIManager()
        popularManager.fetchPopularAPI { [weak self] result in
            switch result {
            case .success(let data):
                self?.popularKeywoard = data
                self?.delegate?.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

