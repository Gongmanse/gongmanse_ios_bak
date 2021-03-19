import UIKit

class WhatIsGongManseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "공만세란?"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
}
