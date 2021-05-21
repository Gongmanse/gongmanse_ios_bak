//
//  SideMenuHeaderView.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/22.
//

import UIKit


protocol SideMenuHeaderViewDelegate: class {
    func handleDismiss()
    func clickedLoginButton()
    func clickedLogoutButton()
    func clickedRegistrationButton()
    func clickedBuyingPassTicketButton()
    
}

class SideMenuHeaderView: UIView {
    
    // MARK: - Properties
    
    var viewModel: SideMenuHeaderViewModel? {
        didSet { commonInit() }
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
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = #imageLiteral(resourceName: "logoIconGray")
        return imageView
    }()
    
    /// 로그인 상태
    let nickName: UILabel = {
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
        sideMenuHeaderViewDelegate?.clickedRegistrationButton()
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
        self.addSubview(profileImage)
        self.addSubview(nickName)
        self.addSubview(membershipLevel)
        self.addSubview(loginBtn)
        self.addSubview(signUpBtn)
        self.addSubview(passTicketContainerView)
        passTicketContainerView.addSubview(buyingPassTicketLabel)
        passTicketContainerView.addSubview(buyingPassTicketButton)
        self.addSubview(bottomBorderView)
        
        closeButton.setDimensions(height: 25, width: 25)
        closeButton.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                           right: self.safeAreaLayoutGuide.rightAnchor,
                           paddingTop: 10,
                           paddingRight: 10)
        
        
        let profileImageConstant = self.frame.height * 0.32
        let viewWidth = self.frame.width
        
        profileImage.addShadow()
        profileImage.setDimensions(height: profileImageConstant,
                                   width: profileImageConstant)
        profileImage.layer.cornerRadius = profileImageConstant * 0.5
        profileImage.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        profileImage.centerX(inView: self)
        profileImage.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                            paddingTop: viewWidth * 0.11)
        
        nickName.centerX(inView: self)
        nickName.anchor(top: profileImage.bottomAnchor,
                        paddingTop: viewWidth * 0.05,
                        height: viewWidth * 0.05)
        
        membershipLevel.centerX(inView: self)
        membershipLevel.anchor(top: nickName.bottomAnchor,
                               paddingTop: viewWidth * 0.019,
                               height: 12.5)
        
        loginBtn.layer.cornerRadius = 10
        loginBtn.setDimensions(height: viewWidth * 0.097,
                               width: viewWidth * 0.35)
        loginBtn.anchor(top: membershipLevel.bottomAnchor,
                        left: self.leftAnchor,
                        paddingTop: viewWidth * 0.043,
                        paddingLeft: viewWidth * 0.125)
        
        signUpBtn.layer.cornerRadius = 10
        signUpBtn.setDimensions(height: viewWidth * 0.097,
                                width: viewWidth * 0.35)
        signUpBtn.anchor(top: membershipLevel.bottomAnchor,
                         right: self.rightAnchor,
                         paddingTop: viewWidth * 0.043,
                         paddingRight: viewWidth * 0.125)
        
        passTicketContainerView.layer.cornerRadius = 10
        passTicketContainerView.setDimensions(height: viewWidth * 0.12,
                                              width: self.frame.width * 0.83)
        passTicketContainerView.centerX(inView: self)
        passTicketContainerView.anchor(top: signUpBtn.bottomAnchor,
                                       paddingTop: viewWidth * 0.023)
        
        
        buyingPassTicketLabel.centerY(inView: passTicketContainerView)
        buyingPassTicketLabel.anchor(left: passTicketContainerView.leftAnchor,
                                     paddingLeft: self.frame.width * 0.066,
                                     height: 13)
        
        buyingPassTicketButton.layer.cornerRadius = 8.5
        buyingPassTicketButton.setDimensions(height: self.frame.height * 0.09,
                                             width: self.frame.width * 0.33)
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
            
            nickName.text = viewModel.name
            print(nickName.text)
            loginBtn.setTitle("로그아웃", for: .normal)
            
            signUpBtn.setTitle("프로필 수정", for: .normal)
            
            buyingPassTicketLabel.text = "이용권 20일 남음"
            
            buyingPassTicketButton.setTitle("사용 기간 연장", for: .normal)
        }
    }
}
