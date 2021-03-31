//
//  FindingPwdVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import UIKit

class FindingPwdVC: UIViewController {

    // MARK: - Propertise
    
    
    // MARK: - Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .red
    }

}
