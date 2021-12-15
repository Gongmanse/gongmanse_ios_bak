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
        return (activateDate != nil) && (activateDate != nil)
    }
    
    // 만약 이용권이 있다면, String로 받아온 값을 Date로 변경한다.
    func dateStringToDate(_ dateString: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        let date: Date = dateFormatter.date(from: dateString)!
        return date
    }
    
    func dateRemainingCalculateByTody(startDate: Date, expireDate: Date) -> Int {
        
        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let result = Int(dateRemaining / 86400)
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
        
        let startDate = dateStringToDate(startDateString)
        let expireDate = dateStringToDate(expireDateString)
        
        let dateRemaining = dateRemainingCalculateByTody(startDate: startDate, expireDate: expireDate)
        if dateRemaining > 0 {
            Constant.remainPremiumDateInt = dateRemaining
        }
        self.dateRemainingString = "\(dateRemaining)"
        
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
