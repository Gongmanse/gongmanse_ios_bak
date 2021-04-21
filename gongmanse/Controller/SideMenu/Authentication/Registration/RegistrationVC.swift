//
//  RegistrationVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//

import UIKit

class RegistrationVC: UIViewController {
    
    // MARK: - Properties
    
    var viewModel = RegistrationVCViewModel()
    
    var isSelected: Bool = false
    var bottomIsSelected: Bool = false
    
    // 이용약관 레이블
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.termOfServiceText
        label.numberOfLines = 0
        label.font = UIFont.appRegularFontWith(size: 12.5)
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        return label
    }()
    
    // 개인정보 레이블
    let bottomtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.termOfServiceText
        label.numberOfLines = 0
        label.font = UIFont.appRegularFontWith(size: 12.5)
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        return label
    }()
    
    // MARK: - IBOutlet
    // 오토레이아웃 - CODE
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    
    // scrollView
    // top
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    
    // bottom
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var bottomScrollViewContainerView: UIView!
    @IBOutlet weak var termsOfInfoLabel: UILabel!
    @IBOutlet weak var termsOfInfoButton: UIButton!
    
    // all Agree
    @IBOutlet weak var allAgreeLabel: UILabel!
    @IBOutlet weak var allAgreeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        cofigureNavi()
        setupScrollView()
        setupViews()
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - Actions
    
    // "다음" 버튼
    @IBAction func handleNextPage(_ sender: Any) {
        if viewModel.agreeIsValid {
            self.navigationController?.pushViewController(RegistrationUserInfoVC(), animated: false)
        } else {
            // 모두 동의를 하지 않은 경우,
            presentAlert(message: "약관에 모두 동의해주세요.")
        }
    }

    // 이용약관 버튼 액션
    @IBAction func handleUpperAgreeBtn(_ sender: UIButton) {
        if termsOfServiceButton.isSelected {    // 비동의
            termsOfServiceButton.isSelected = false
            viewModel.firstAgree = false
            if !viewModel.agreeIsValid {
                allAgreeButton.isSelected = false
            }
        } else {                                // 동의
            termsOfServiceButton.isSelected = true
            viewModel.firstAgree = true
            if viewModel.secondAgree {
                allAgree(true)
            }
        }
    }
    
    // 개인정보 수집 및 이용 동의 액션
    @IBAction func handleBottomAgreeBtn(_ sender: UIButton) {
        if termsOfInfoButton.isSelected {
            termsOfInfoButton.isSelected = false
            viewModel.secondAgree = false
            if !viewModel.agreeIsValid {
                allAgreeButton.isSelected = false
            }
        } else {
            termsOfInfoButton.isSelected = true
            viewModel.secondAgree = true
            if viewModel.firstAgree {
                allAgree(true)
            }
            
            
        }
    }
    
    @IBAction func handleAllAgreeBtn(_ sender: Any) {
        if allAgreeButton.isSelected {
            viewModel.firstAgree = false
            viewModel.secondAgree = false
            allAgree(false)
        } else if (allAgreeButton.isSelected == false) {
            viewModel.firstAgree = true
            viewModel.secondAgree = true
            allAgree(true)
        }
    }
    
    // TODO: 모두 동의 로직, 추후 코드 리펙토링 필요
    func allAgree(_ index: Bool) {
        allAgreeButton.isSelected = index
        termsOfInfoButton.isSelected = index
        termsOfServiceButton.isSelected = index
    }
    

    // MARK: - Helper functions
    
    func configureUI() {
        tabBarController?.tabBar.isHidden = true
        
        nextButton.backgroundColor = UIColor.progressBackgroundColor
        nextButton.layer.cornerRadius = 10
        nextButton.addShadow()
        // ProgressView 오토레이아웃
        totalProgressView.centerX(inView: view)
        totalProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: 4)
        totalProgressView.backgroundColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
        
        currentProgressView.setDimensions(height: 4, width: view.frame.width * 0.25)
        currentProgressView.anchor(top:totalProgressView.topAnchor,
                                   left: totalProgressView.leftAnchor)
        currentProgressView.backgroundColor = .mainOrange
        
        pageID.setDimensions(height: view.frame.height * 0.02,
                             width: view.frame.width * 0.15)
        pageID.anchor(top: totalProgressView.bottomAnchor,
                      left: totalProgressView.leftAnchor,
                      paddingTop: 11,
                      paddingLeft: 20)
        pageID.font = UIFont.appBoldFontWith(size: 14)
        pageID.textAlignment = .left
        
        pageNumber.setDimensions(height: view.frame.height * 0.02,
                                 width: view.frame.width * 0.15)
        pageNumber.anchor(top: totalProgressView.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 11,
                          paddingRight: 20)
        pageNumber.font = UIFont.appBoldFontWith(size: 14)
        pageNumber.textAlignment = .right
        
        // termsOfServiceButton
        termsOfServiceButton.setDimensions(height: termsOfServiceLabel.frame.height,
                                           width: termsOfServiceLabel.frame.height)
        termsOfServiceButton.anchor(top: scrollViewContainerView.bottomAnchor,
                                   left: scrollViewContainerView.leftAnchor,
                                   paddingTop: 5,
                                   paddingLeft: 0)
        termsOfServiceButton.setImage(UIImage(named: "checkFalse"), for: .normal)
        termsOfServiceButton.setImage(UIImage(named: "checkTrue"), for: .selected)
        
        // termsOfServiceLabel
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "이용 약관 동의",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributedString.append(NSAttributedString(string: "(필수)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange]))
        termsOfServiceLabel.attributedText = attributedString
        termsOfServiceLabel.font = UIFont.appBoldFontWith(size: 13)
        termsOfServiceLabel.setDimensions(height: view.frame.height * 0.0175, width: view.frame.width * 0.33)
        termsOfServiceLabel.centerY(inView: termsOfServiceButton)
        termsOfServiceLabel.anchor(left: termsOfServiceButton.leftAnchor,
                                   paddingLeft: termsOfServiceButton.frame.width - 5)

        // termsOfInfoButton
        termsOfInfoButton.setDimensions(height: termsOfServiceLabel.frame.height,
                                           width: termsOfServiceLabel.frame.height)
        termsOfInfoButton.anchor(top: bottomScrollViewContainerView.bottomAnchor,
                                   left: scrollViewContainerView.leftAnchor,
                                   paddingTop: 5,
                                   paddingLeft: 0)
        termsOfInfoButton.setImage(UIImage(named: "checkFalse"), for: .normal)
        termsOfInfoButton.setImage(UIImage(named: "checkTrue"), for: .selected)

        
        
        // termsOfInfoLabel
        let attributedString2 = NSMutableAttributedString(string: "개인정보 수집 및 이용 동의",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributedString2.append(NSAttributedString(string: "(필수)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange]))
        termsOfInfoLabel.attributedText = attributedString
        termsOfInfoLabel.font = UIFont.appBoldFontWith(size: 13)
        termsOfInfoLabel.setDimensions(height: view.frame.height * 0.0175, width: view.frame.width * 0.33)
        termsOfInfoLabel.centerY(inView: termsOfInfoButton)
        termsOfInfoLabel.anchor(left: termsOfInfoButton.leftAnchor,
                                   paddingLeft: termsOfInfoButton.frame.width - 5)
        
        // allAgreeButton
        allAgreeButton.setDimensions(height: termsOfServiceLabel.frame.height,
                                           width: termsOfServiceLabel.frame.height)
        allAgreeButton.anchor(top: termsOfInfoButton.bottomAnchor,
                                   left: termsOfInfoButton.leftAnchor,
                                   paddingTop: 17)
        allAgreeButton.setImage(UIImage(named: "checkFalse"), for: .normal)
        allAgreeButton.setImage(UIImage(named: "checkTrue"), for: .selected)
        
        // allAgreeLabel
        allAgreeLabel.textColor = UIColor.black
        allAgreeLabel.font = UIFont.appBoldFontWith(size: 13)
        allAgreeLabel.setDimensions(height: view.frame.height * 0.0175, width: view.frame.width * 0.8)
        allAgreeLabel.centerY(inView: allAgreeButton)
        allAgreeLabel.anchor(left: allAgreeButton.leftAnchor,
                                   paddingLeft: allAgreeButton.frame.width - 5)
        

    }

    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }
    
}





// MARK: - Setting ScrollView

private extension RegistrationVC {
    func setupScrollView() {
        // top
        //  ScrollView container (그림자 효과를 주기 위해서)
        scrollViewContainerView.setDimensions(height: view.frame.height * 0.23,
                                    width: view.frame.width * 0.74)
        scrollViewContainerView.centerX(inView: view)
        scrollViewContainerView.anchor(top: totalProgressView.bottomAnchor,
                             paddingTop: 45)
        scrollViewContainerView.layer.cornerRadius = 10
        scrollViewContainerView.layer.masksToBounds = true
        scrollViewContainerView.clipsToBounds = true
        scrollViewContainerView.addShadow()
        
        // topScrollView
        topScrollView.layer.cornerRadius = 10
        topScrollView.backgroundColor = .white
        topScrollView.anchor(top: scrollViewContainerView.topAnchor,
                             left: scrollViewContainerView.leftAnchor,
                             bottom: scrollViewContainerView.bottomAnchor,
                             right: scrollViewContainerView.rightAnchor)
    
        // topContentView
        topContentView.centerX(inView: topScrollView)
        topContentView.backgroundColor = .white
        topContentView.anchor(top: topScrollView.topAnchor,
                              bottom: topScrollView.bottomAnchor,
                              width: topScrollView.frame.width)
        
        // bottom
        // ScrollView container (그림자 효과를 주기 위해서)
        bottomScrollViewContainerView.setDimensions(height: view.frame.height * 0.23,
                                    width: view.frame.width * 0.74)
        bottomScrollViewContainerView.centerX(inView: view)
        bottomScrollViewContainerView.anchor(top: termsOfServiceLabel.bottomAnchor,
                             paddingTop: 20)
        bottomScrollViewContainerView.layer.cornerRadius = 10
        bottomScrollViewContainerView.layer.masksToBounds = true
        bottomScrollViewContainerView.clipsToBounds = true
        bottomScrollViewContainerView.addShadow()
        
        // topScrollView
        bottomScrollView.layer.cornerRadius = 10
        bottomScrollView.backgroundColor = .white
        bottomScrollView.anchor(top: bottomScrollViewContainerView.topAnchor,
                             left: bottomScrollViewContainerView.leftAnchor,
                             bottom: bottomScrollViewContainerView.bottomAnchor,
                             right: bottomScrollViewContainerView.rightAnchor)
    
        // topContentView
        bottomContentView.centerX(inView: topScrollView)
        bottomContentView.backgroundColor = .white
        bottomContentView.anchor(top: bottomScrollView.topAnchor,
                              bottom: bottomScrollView.bottomAnchor,
                              width: bottomScrollView.frame.width)
    }
    
    func setupViews() {
        // top: label in ScrollView - contentView
        topContentView.addSubview(titleLabel)
        titleLabel.centerX(inView: topContentView)
        titleLabel.anchor(top: topContentView.topAnchor,
                          bottom: topContentView.bottomAnchor,
                          width: topContentView.frame.width * 0.9)
        
        // bottom: label in ScrollView - contentView
        bottomContentView.addSubview(bottomtitleLabel)
        bottomtitleLabel.centerX(inView: bottomContentView)
        bottomtitleLabel.anchor(top: bottomContentView.topAnchor,
                          bottom: bottomContentView.bottomAnchor,
                          width: bottomContentView.frame.width * 0.9)
    }
}
