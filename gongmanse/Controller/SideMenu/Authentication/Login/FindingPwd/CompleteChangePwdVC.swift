//
//  CompleteChangePwdVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

//import UIKit
//
//class CompleteChangePwdVC: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

import UIKit

class CompleteChangePwdVC: UIViewController {
    
    // MARK: - Properties

//    var viewModel: FindingIDByPhoneViewModel?   // FindIDByPhoneVC 의 viewModel을 전달받을 Property
    
    var pageIndex: Int!
    
    // 최상단에 있는 이미지
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "settings")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 변경이 완료되었습니다."
        label.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "비밀번호 변경",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange])
        
        attributedString.append(NSAttributedString(string: "이 완료되었습니다.",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        label.attributedText = attributedString
        label.font = UIFont.appEBFontWith(size: 22)
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 13)
        label.textColor = UIColor.progressBackgroundColor
        label.text = "지금 바로 공만세에 로그인을 해서\n여러 서비스를 이용해보세요!"
        return label
    }()
        
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
//        guard let viewModel = viewModel else { return }
//        FindingIDDataManager().findingIDResultByPhone(FindingIDResultInput(receiver: viewModel.cellPhone, name: viewModel.name),
//                                                      viewController: self)
    }
    
    
    // MARK: - Actions
    
    @objc func handleLogin() {
        // 중간 스텍의 컨트롤러로 화면 이동하기 위한 로직
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for vc in viewControllers {
            if vc is LoginVC {
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController!.popToViewController(vc, animated: true)
            }
        }
    }

    // MARK: - Helpers
    
    func configureUI() {
        // 오토레이아웃 종속관계에 때문에 "아이디 찾기가.." 를 우선 선언함.
        
        // "아이디 찾기가 완료되었습니다." 레이블
        view.addSubview(titleLabel)
        titleLabel.setDimensions(height: 25, width: view.frame.width * 0.9)
        titleLabel.centerX(inView: view)
        titleLabel.centerY(inView: view, constant: -(view.frame.height * 0.09))
        
        // 이미지
        view.addSubview(mainImage)
        mainImage.setDimensions(height: 87, width: 87)
        mainImage.centerX(inView: view)
        mainImage.anchor(bottom: titleLabel.topAnchor,
                         paddingBottom: view.frame.height * 0.04)
        
        // "지금바로 .. 이용해보세요!" 레이블
        view.addSubview(bottomLabel)
        bottomLabel.setDimensions(height: 34, width: 200)
        bottomLabel.centerX(inView: view)
        bottomLabel.anchor(top: titleLabel.bottomAnchor,
                           paddingTop: view.frame.height * 0.02)
        
        // "로그인" UIButton
        view.addSubview(loginButton)
        loginButton.setDimensions(height: 40, width: 135)
        loginButton.centerX(inView: view)
        loginButton.anchor(top: bottomLabel.bottomAnchor,
                           paddingTop: view.frame.height * 0.1)
    }

}


// MARK: - API

extension CompleteChangePwdVC {
    func didSucceedVaildation(_ response: FindingIDResultResponse) {
//        guard let result = response.sUsername else { return }
//        idLabel.text = result
    }
}
