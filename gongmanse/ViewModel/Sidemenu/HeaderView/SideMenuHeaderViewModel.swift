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
    var profileImageURL: String?
    var passTicketDate = "0"
    var token = ""
    var headerViewHeight: CGFloat?
    var activateDate: String?
    var expireDate: String?
    var dateRemainingString: String?
    var reloadDelegate: TableReloadData?
    
    init() {
        
    }
    
    deinit {
        print("SideMenuHeaderViewModel Deinit")
    }
    
    public init(token: String, userID: String) {
        self.token = token
        self.userID = userID
    }
    
    
    var isLogin: Bool {
        return token.count > 3
    }
    
    var isHeaderHeight: CGFloat {
        return isLogin ? 280 : 240
    }
    
    // 이용권 소유 여부를 판단한다.
    var hasPreminum: Bool {
        guard let _ = self.activateDate else { return false }
        guard let expireDateString = self.expireDate else { return false }
        let expireDate = dateStringToDate(expireDateString)
        
        // 만료일 남은 시간 계산하여 리턴
        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        return dateRemaining > 0
    }
    
    func dateRemainingCalculateByTody(startDate: Date, expireDate: Date) -> Int {        
        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        var result = Int(dateRemaining / 86400)//만 하루가 남아있을 경우 1일...
        if result < 0 { result = 0 }
        return result
    }
    
    
    func dateRemainingCalculate(startDate: Date, expireDate: Date) -> Int {
        
        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
        let result = Int(dateRemaining / 86400)
        return result
    }
    
    /// 이용권 남은 일자를 나타내는 연산프로퍼티
    /// - "dateStringToDate(_:)" 메소드를 통해 String을 Date로 형변환
    /// - "dateRemainingCalculate(startDate:expireDate:)" 메소드를 통해 Date를 Int로 형변환
    /// - Date -> Int 로 형변환할 때, day 를 기준으로 연산
    var dateRemaining: String {
        
        guard let startDateString = self.activateDate else { return "" }
        guard let expireDateString = self.expireDate else { return "" }
        
        Constant.dtPremiumActivate = startDateString
        Constant.dtPremiumExpire = expireDateString
        
        let startDate = dateStringToDate(startDateString)
        let expireDate = dateStringToDate(expireDateString)
        
//        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let dayRemaining = dateRemainingCalculateByTody(startDate: startDate, expireDate: expireDate)
//        if dateRemaining > 0 {//시간 조회
//            Constant.remainPremiumDateInt = dayRemaining//날짜표기 nill 체크 시 사용
//        }
        self.dateRemainingString = "\(dayRemaining)"
        
        return dateRemainingString!
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
