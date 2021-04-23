//
//  SideMenuHeaderViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/23.
//

import Foundation
import UIKit.UIImage

class SideMenuHeaderViewModel {
    var name: String = "test"
    var profileImage: UIImage = #imageLiteral(resourceName: "idOff")
    var passTicketDate = "0"
    var token = ""
    var headerViewHeight: CGFloat?
    
    public init(token: String) {
        self.token = token
    }
    
    var isLogin: Bool {
        return token.count > 3
    }
    
    var isHeaderHeight: CGFloat {
        guard let headerViewHeight = headerViewHeight else { return 0}
        return isLogin ? headerViewHeight * 0.41 : headerViewHeight * 0.31
    }
}
