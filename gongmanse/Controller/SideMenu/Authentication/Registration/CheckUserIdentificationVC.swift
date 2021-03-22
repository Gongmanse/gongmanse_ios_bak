//
//  CheckUserIdentificationVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class CheckUserIdentificationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        
    }


    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

}


// MARK: - 회원가입API post

extension CheckUserIdentificationVC {
    func didSuccessRegistration(message: String) {
        // TODO: 회원가입 성공 시, 진행할 로직 작성할 것.
    }
    
    func failedToRequest(message: String) {
        
    }
}
