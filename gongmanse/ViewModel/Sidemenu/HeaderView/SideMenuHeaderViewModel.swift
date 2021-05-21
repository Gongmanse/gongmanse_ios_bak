//
//  SideMenuHeaderViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/23.
//

import Foundation
import UIKit.UIImage

class SideMenuHeaderViewModel {
    var name: String = ""
    var userID: String = ""
    var profileImage: UIImage = #imageLiteral(resourceName: "idOff")
    var passTicketDate = "0"
    var token = ""
    var headerViewHeight: CGFloat?
    
    var reloadDelegate: TableReloadData?
    
    public init(token: String, userID: String) {
        self.token = token
        self.userID = userID
    }
    
    var isLogin: Bool {
        return token.count > 3
    }
    
    var isHeaderHeight: CGFloat {
        guard let headerViewHeight = headerViewHeight else { return 0}
        return isLogin ? headerViewHeight * 0.41 : headerViewHeight * 0.31
    }
    
    init() {
        
    }
    deinit {
        print("SideMenuHeaderViewModel Deinit")
    }
    func requestProfileApi(_ token: String) {
        let profileApi = LoginGetProfileManager()
        profileApi.profileGetApi(token) { response in
            switch response {
            case .success(let data):
                // Nickname 만 저장함
                self.name = data.sNickname ?? ""
                print(self.name)
                self.reloadDelegate?.reloadTable()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
