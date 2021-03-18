//
//  SearchVideoViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import Foundation
import UIKit

struct SearchVideoViewModel {

    let search: Search
    
    var title: String {
        return search.title
    }
    
    var writer: String {
        return search.writer
    }
    

    // TODO: Rating, Tag 구현해야함.

    init(search : Search) {
        self.search = search
    } 
}
