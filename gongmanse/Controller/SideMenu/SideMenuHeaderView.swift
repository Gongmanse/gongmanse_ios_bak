//
//  SideMenuHeaderView.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/22.
//

import UIKit
import SDWebImage

protocol SideMenuHeaderViewDelegate: AnyObject {
    
    func handleDismiss()
    func clickedLoginButton()
    func clickedLogoutButton()
    func clickedRegistrationButton(isLogin: Bool)
    func clickedBuyingPassTicketButton()
}

class SideMenuHeaderView: UIView {
    
    // MARK: - Properties
    
    var viewModel: SideMenuHeaderViewModel? {
        didSet {
            commonInit()
//            updateUI()
        }
    }
    
    weak var sideMenuHeaderViewDelegate: SideMenuHeaderViewDelegate?
    
    /// "X" 버튼
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "close24Px"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    
    /// 프로필 이미지
    public var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
//        imageView.image = #imageLiteral(resourceName: "logoIconGray")
        return imageView
    }()
    
    public var defaultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "logoIconGray")
        return imageView
    }()
    
    /// 로그인 상태
    public var nickName: UILabel = {
        let label = UILabel()
        label.text = "공만세 (master)"
        label.textColor = .mainOrange
        label.font = UIFont.appBoldFontWith(size: 12)
        return label
    }()
    
    /// 로그인 설명
    let membershipLevel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 12)
        label.text = "공만세 님은 일반 회원입니다."
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        return stack
    }()
    
    /// 로그인 버튼
    private let loginBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.titleLabel?.textColor = UIColor.white
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = .mainOrange
        button.addTarget(self, action: #selector(clickedLoginButton), for: .touchUpInside)
        return button
    }()
    
    
    /// 회원가입 버튼
    private let signUpBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 164, green: 164, blue: 164)
        button.addTarget(self, action: #selector(clickedRegistrationButton), for: .touchUpInside)
        return button
    }()
    
    /// 이용권 객체를 담을 View
    let passTicketContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        return view
    }()
    
    /// "이용권을 구매해주세요" or "이용권 00일 남음" 레이블
    private let buyingPassTicketLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.appBoldFontWith(size: 12)
        label.text = "이용권을 구매해주세요."
        return label
    }()
    
    /// "이용권 구매" or "사용 기간" 연장 버튼
    private let buyingPassTicketButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.appRegularFontWith(size: 12)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("이용권 구매", for: .normal)
        button.addTarget(self, action: #selector(clickedBuyingPassTicketButton), for: .touchUpInside)
        return button
    }()
    
    private let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    func handleDismiss() {
        sideMenuHeaderViewDelegate?.handleDismiss()
    }
    
    
    @objc
    func clickedLoginButton() {
        if let viewModel = viewModel {
            if viewModel.isLogin {
                sideMenuHeaderViewDelegate?.clickedLogoutButton()
            } else {
                sideMenuHeaderViewDelegate?.clickedLoginButton()
            }
        }
        
    }
    
    @objc
    func handleLogout() {
        sideMenuHeaderViewDelegate?.clickedLogoutButton()
    }
    
    @objc
    func clickedRegistrationButton() {
        if let viewModel = viewModel {
            let isLogin = viewModel.isLogin
            sideMenuHeaderViewDelegate?.clickedRegistrationButton(isLogin: isLogin)
        }
    }
    
    @objc
    func clickedBuyingPassTicketButton() {
        sideMenuHeaderViewDelegate?.clickedBuyingPassTicketButton()
    }
    
    
    // MARK: - Helpers
    
    func commonInit() {
        configureUI()
        updateUI()
    }
    
    /// 최초 초기화 시, UI구현을 위한 메소드
    func configureUI() {
        self.addSubview(closeButton)
        self.addSubview(profileImageView)
        self.addSubview(defaultImageView)
        self.addSubview(nickName)
        self.addSubview(membershipLevel)
//        self.addSubview(loginBtn)
//        self.addSubview(signUpBtn)
        self.addSubview(stackView)
        self.addSubview(passTicketContainerView)
        passTicketContainerView.addSubview(buyingPassTicketLabel)
        passTicketContainerView.addSubview(buyingPassTicketButton)
        self.addSubview(bottomBorderView)
        
        closeButton.setDimensions(height: 25, width: 25)
        closeButton.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                           right: self.safeAreaLayoutGuide.rightAnchor,
                           paddingTop: 10,
                           paddingRight: 10)
        
        
        let profileImageConstant = CGFloat(88)
        let viewWidth = CGFloat(331)
        
        profileImageView.addShadow()
        profileImageView.clipsToBounds = true
        profileImageView.setDimensions(height: profileImageConstant,
                                   width: profileImageConstant)
        profileImageView.layer.cornerRadius = profileImageConstant * 0.5
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        profileImageView.centerX(inView: self)
        profileImageView.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                            paddingTop: viewWidth * 0.11)
        
        defaultImageView.setDimensions(height: profileImageConstant,
                                   width: profileImageConstant)
        defaultImageView.centerX(inView: profileImageView)
        defaultImageView.centerY(inView: profileImageView)
        
        nickName.centerX(inView: self)
        nickName.anchor(top: profileImageView.bottomAnchor,
                        paddingTop: viewWidth * 0.05,
                        height: viewWidth * 0.05)
        
        membershipLevel.centerX(inView: self)
        membershipLevel.anchor(top: nickName.bottomAnchor,
                               paddingTop: viewWidth * 0.019,
                               height: 12.5)
        
        loginBtn.layer.cornerRadius = 10
        loginBtn.setDimensions(height: viewWidth * 0.097,
                               width: viewWidth * 0.35)
//        loginBtn.anchor(top: membershipLevel.bottomAnchor,
//                        left: self.leftAnchor,
//                        paddingTop: viewWidth * 0.043,
//                        paddingLeft: viewWidth * 0.125)
        
        signUpBtn.layer.cornerRadius = 10
        signUpBtn.setDimensions(height: viewWidth * 0.097,
                                width: viewWidth * 0.35)
//        signUpBtn.anchor(top: membershipLevel.bottomAnchor,
//                         right: self.rightAnchor,
//                         paddingTop: viewWidth * 0.043,
//                         paddingRight: viewWidth * 0.125)
        
        stackView.addArrangedSubview(loginBtn)
        stackView.addArrangedSubview(signUpBtn)
        stackView.centerX(inView: self)
        stackView.anchor(top: membershipLevel.bottomAnchor,
                               paddingTop: viewWidth * 0.019)
        
        passTicketContainerView.layer.cornerRadius = 10
        passTicketContainerView.setDimensions(height: viewWidth * 0.12,
                                              width: viewWidth * 0.83)
        passTicketContainerView.centerX(inView: self)
        passTicketContainerView.anchor(top: signUpBtn.bottomAnchor,
                                       paddingTop: viewWidth * 0.023)
        
        
        buyingPassTicketLabel.centerY(inView: passTicketContainerView)
        buyingPassTicketLabel.anchor(left: passTicketContainerView.leftAnchor,
                                     paddingLeft: viewWidth * 0.066,
                                     height: 13)
        
        buyingPassTicketButton.layer.cornerRadius = 8.5
        buyingPassTicketButton.setDimensions(height: 25,
                                             width: viewWidth * 0.33)
        buyingPassTicketButton.centerY(inView: passTicketContainerView)
        buyingPassTicketButton.anchor(right: passTicketContainerView.rightAnchor,
                                      paddingRight: 5)
        
        bottomBorderView.setDimensions(height: 3, width: self.frame.width)
        bottomBorderView.centerX(inView: self)
        bottomBorderView.anchor(bottom: self.bottomAnchor)
    }
    
    /// 로그인 여부에 따른 UI 업데이트를 위한 메소드
    func updateUI() {
        
        guard let viewModel = viewModel else { return }
        
        if viewModel.isLogin {
            
            nickName.text = viewModel.userID
            membershipLevel.text = "\(viewModel.userID)님은 일반 회원입니다."
            let profileImageConstant = CGFloat(88)

            if let imageURL = viewModel.profileImageURL {
                self.defaultImageView.isHidden = true
                profileImageView.sd_setImage(with: URL(string: "\(fileBaseURL)/"+imageURL)!) { image, Error, SDImageCacheType, URL in
                    self.profileImageView.addShadow()
                    self.profileImageView.image = image
                    self.profileImageView.clipsToBounds = true
                    self.profileImageView.layer.masksToBounds = true
                }
            } else {
                self.defaultImageView.isHidden = false
            }
            self.profileImageView.layer.cornerRadius = profileImageConstant * 0.5

            loginBtn.setTitle("로그아웃", for: .normal)
//            loginBtn.centerX(inView: self)
            loginBtn.updateConstraints()
        
            signUpBtn.setTitle("프로필 수정", for: .normal)
            signUpBtn.alpha = 1
            
            if viewModel.hasPreminum {
                // 이용권 n일 남음 + 사용 기간 연장
                buyingPassTicketLabel.text = "이용권     "
                    + viewModel.dateRemaining + "일 남음"
                buyingPassTicketButton.setTitle("사용 기간 연장",
                                                for: .normal)
            } else {
                buyingPassTicketLabel.text = "이용권을 구매해주세요."
                buyingPassTicketButton.setTitle("이용권 구매",
                                                for: .normal)
            }
            
            
            
            
        } else {
            self.defaultImageView.isHidden = false
            nickName.text = "로그인을 해주세요."
            membershipLevel.text = "로그인하고 더 많은 서비스를 누리세요."
        }
    }
}
