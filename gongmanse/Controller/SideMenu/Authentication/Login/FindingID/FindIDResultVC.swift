//
//  FindIDResultVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//

import UIKit

class FindIDResultVC: UIViewController {
    
    // MARK: - Properties

    var viewModel: FindingIDByPhoneViewModel?   // FindIDByPhoneVC 의 viewModel을 전달받을 Property
    
    var pageIndex: Int!
    
    // 최상단에 있는 이미지
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "settings")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디 찾기가 완료되었습니다."
        let attributedString = NSMutableAttributedString(string: "아이디 찾기",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange])
        
        attributedString.append(NSAttributedString(string: "가 완료되었습니다.",
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
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "woosungs"
        label.font = UIFont.appBoldFontWith(size: 20)
        return label
    }()
    
    private let id: UILabel = {
        let label = UILabel()
        label.text = "아이디"
        label.textColor = UIColor.progressBackgroundColor
        label.font = UIFont.appBoldFontWith(size: 13)
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.progressBackgroundColor
        return view
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
    
    private let findPwdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호 찾기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .progressBackgroundColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleFindingPwd), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        guard let viewModel = viewModel else { return }
        FindingIDDataManager().findingIDResultByPhone(FindingIDResultInput(receiver: viewModel.cellPhone, name: viewModel.name),
                                                      viewController: self)
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
    
    @objc func handleFindingPwd() {
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.pushViewController(FindingPwdVC(), animated: true)
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        
        // 이미지
        view.addSubview(mainImage)
        mainImage.setDimensions(height: 87, width: 87)
        mainImage.centerX(inView: view)
        mainImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: 75)
        
        // "아이디 찾기가 완료되었습니다." 레이블
        view.addSubview(titleLabel)
        titleLabel.setDimensions(height: 25, width: 264)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: mainImage.bottomAnchor,
                          paddingTop: 14)
        
        // "지금바로 .. 이용해보세요!" 레이블
        view.addSubview(bottomLabel)
        bottomLabel.setDimensions(height: 34, width: 200)
        bottomLabel.centerX(inView: view)
        bottomLabel.anchor(top: titleLabel.bottomAnchor,
                           paddingTop: 18)
        
        // 아이디찾기를 통해 찾은 아이디
        view.addSubview(idLabel)
        idLabel.centerX(inView: view)
        idLabel.anchor(top: bottomLabel.bottomAnchor,
                       paddingTop: 50, height: 34)
        
        // "아이디"
        view.addSubview(id)
        id.setDimensions(height: 18, width: 42)
        id.centerY(inView: idLabel)
        id.anchor(left: view.leftAnchor,
                  paddingLeft: 75)

        // 구분선
        view.addSubview(divider)
        divider.setDimensions(height: 2, width: 240)
        divider.centerX(inView: view)
        divider.anchor(top: idLabel.bottomAnchor,
                       paddingTop: 7.5)
        
        
        // "로그인" UIButton
        view.addSubview(loginButton)
        loginButton.setDimensions(height: 40, width: 135)
        loginButton.anchor(top: divider.bottomAnchor,
                           left: view.leftAnchor,
                           paddingTop: 50, paddingLeft: 50)

        // "로그인" UIButton
        view.addSubview(findPwdButton)
        findPwdButton.setDimensions(height: 40, width: 135)
        findPwdButton.anchor(top: divider.bottomAnchor,
                           right: view.rightAnchor,
                           paddingTop: 50, paddingRight: 50)
    }

}


// MARK: - API

extension FindIDResultVC {
    func didSucceedVaildation(_ response: FindingIDResultResponse) {
        guard let result = response.sUsername else { return }
        idLabel.text = result
    }
}
