//
//  RegistrationCompletionVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class RegistrationCompletionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        // Do any additional setup after loading the view.
    }


    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

}
