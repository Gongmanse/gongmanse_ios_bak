//
//  InfinityScroll.swift
//  gongmanse
//
//  Created by wallter on 2021/06/10.
//

import Foundation

protocol ProgressInfinityScroll: class {
    var islistMore: Bool? { get set }
    var listCount: Int { get set }
    func scrollMethod()
}

protocol SearchInfinityScroll: class {
    var infinityBool: Bool { get set }
    var allIntiniteScroll: Bool { get set }
    var listCount: Int { get set }
}
