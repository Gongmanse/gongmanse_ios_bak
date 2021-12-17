/*  LoginVC.swift
 *
 * 홈 > 사이드메뉴 > 로그인 클릭 시, 호출되는 컨트롤러입니다.
 * 로그인 버튼 클릭 시, 로그인 API관련 메소드가 호출되고, 이에 대한 결과를 Response 해줍니다.
 * 1. 사용자가 입력한 아이디와 비밀번호가 일치하면, "홈" 으로 이동합니다.
 * 2. 불일치하면, 불일치 경고 View를 호출합니다.
*/

import UIKit

class LoginVC: UIViewController {
    
    // MARK: - IBOutlet
    
    /// 로그인 화면을 담당하는 ViewModel
    var viewModel = LogInViewModel()
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var findingIDButton: UIButton!
    @IBOutlet weak var findingPasswordButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    /// 비밀번호 찾기 좌측 구분선
    let leftDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    /// 비밀번호 찾기 우측 구분선
    let rightDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupUI()
        cofigureNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - Actions
    
    /// 로그인 화면 종료 시, 호출되는 Callback method
    @IBAction func handleDismiss(_ sender: Any) {
        // 화면전환 직전에, 내비게이션 바와 탭 바 생성
        self.navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 로그인 버튼 클릭 시, 호출되는 Callback method
    @IBAction func handleLogin(_ sender: Any) {
        LoginDataManager().sendingLoginInfo(LoginInput(usr: "\(viewModel.username)", pwd: "\(viewModel.password)"), viewController: self)
        
    }
    
    /// 아이디찾기 버튼 클릭 시, 호출되는 Callback method
    @IBAction func handleFindingID(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = FindingIDVC(nibName: "FindingIDVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 비밀번호 찾기 버튼 클릭 시, 호출되는 Callback method
    @IBAction func handleFindingPW(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = FindingPwdVC(nibName: "FindingPwdVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 회원가입 버튼 클릭 시, 호출되는 Callback method
    @IBAction func handleRegistration(_ sender: Any) {
        let controller = RegistrationVC()
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        
        // UI 메모리 로드 이후, 내비게이션 바와 탭 바 제거한다.
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        loginButton.addShadow()
        
        
        /// width 값을 위한 프로퍼티
        let tfWidth = Constant.width - 40
        
        // 아이디 TextField leftView를 추가한다.
        let idImage = #imageLiteral(resourceName: "idOn")
        let idleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let idimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        idimageView.image = idImage
        idleftView.addSubview(idimageView)
        
        // 비밀번호 TextField leftView를 추가한다.
        let passwordImage = #imageLiteral(resourceName: "passwordOn")
        let passwordleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let passwordimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        passwordimageView.image = passwordImage
        passwordleftView.addSubview(passwordimageView)
        
        /* UITextField setting */
        // 아이디 Textfield 관련 설정을 한다.
        idTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(idTextField, placehoder: "아이디", leftView: idleftView)
        idTextField.centerX(inView: view)
        idTextField.anchor(top: logoImage.bottomAnchor,
                           paddingTop: view.frame.height * 0.1)
        
        // 비밀번호 Textfield 관련 설정을 한다.
        passwordTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(passwordTextField, placehoder: "비밀번호", leftView: passwordleftView)
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.centerX(inView: view)
        passwordTextField.anchor(top: idTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 로그인 Button 관련 설정을 한다.
        loginButton.backgroundColor = .mainOrange
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.appBoldFontWith(size: 17)
        loginButton.centerX(inView: view)
        loginButton.anchor(top: passwordTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.05)
        loginButton.setDimensions(height: 40,
                                  width: Constant.width - 80)
        
        // 아이디 찾기 Button 관련 설정을 한다.
        findingIDButton.setDimensions(height: 18, width: 78)
//        findingIDButton.anchor(top: loginButton.bottomAnchor,
//                               left: view.safeAreaLayoutGuide.leftAnchor,
//                               paddingTop: view.frame.height * 0.05,
//                               paddingLeft: 15)
        findingIDButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
        // 비밀번호 찾기 Button 관련 설정을 한다.
        findingPasswordButton.setDimensions(height: 18, width: 85)
//        findingPasswordButton.centerX(inView: view)
//        findingPasswordButton.anchor(top: findingIDButton.topAnchor)
        findingPasswordButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
        /// 좌측 구분선
//        let leftXPoint = (view.center.x * 0.5) + 30
//        view.addSubview(leftDividerView)
        leftDividerView.setDimensions(height: 18, width: 1)
//        leftDividerView.anchor(left: logoImage.leftAnchor)
//        leftDividerView.anchor(top: findingPasswordButton.topAnchor)
//                               left: view.leftAnchor,
//                           paddingLeft: leftXPoint)
        
        /// 우측 구분선
//        let rightXPoint = (view.center.x * 0.5) + 30
//        view.addSubview(rightDividerView)
        rightDividerView.setDimensions(height: 18, width: 1)
//        rightDividerView.anchor(right: logoImage.rightAnchor)
//        rightDividerView.anchor(top: findingPasswordButton.topAnchor)
//                           right: view.rightAnchor,
//                           paddingRight: rightXPoint)
        
        // 회원가입 Button 관련 설정을 한다.
        registrationButton.setDimensions(height: 18, width: 78)
//        registrationButton.anchor(top: findingIDButton.topAnchor,
//                                  right: view.safeAreaLayoutGuide.rightAnchor,
//                                  paddingRight: 15)
        registrationButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(findingIDButton)
        stackView.addArrangedSubview(leftDividerView)
        stackView.addArrangedSubview(findingPasswordButton)
        stackView.addArrangedSubview(rightDividerView)
        stackView.addArrangedSubview(registrationButton)
        
        stackView.anchor(top: loginButton.bottomAnchor,
                                       left: view.safeAreaLayoutGuide.leftAnchor,
                                       right: view.safeAreaLayoutGuide.rightAnchor,
                                       paddingTop: view.frame.height * 0.05,
                                       paddingLeft: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 30,
                                       paddingRight: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 30)
    }
    
    /// UITextField 에서 텍스트 변경될 때마다, 호출되는 Callback method
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        /// 텍스트 필드 확인을 위한 switch문
        /// - idTextField 인 경우, 아이디를 입력받는 Textfield
        /// - passwordTextField 인 경우, 비밀번호를 입력받는 Textfield
        switch sender {
        case idTextField:
            viewModel.username = text
            
        case passwordTextField:
            viewModel.password = text
            
        default:
            print("DEBUG: default Setting")
        }
    }
    
    /// UITextField 콜백메소드 추가 메소드
    func cofigureNotificationObservers() {
        idTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    /// 잘못된 아이디와 비밀번호를 입력했을 때, 보여주기 위한 경고창 로직 메소드
    func showAlertMessage() {
        
    }
    
}


// MARK: - TapGesture

/// UITextField 클릭 시, 제스쳐를 추가하기 위한 extension
/// UITextField가 서브클래싱된 객체이므로 커스터마이징 과정에서 아래 로직을 추가
private extension LoginVC {
    
    @objc func tapGesture() {
        view.endEditing(true)
    }
    
    func setupUI() {
        setupTapGesture()
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}


// MARK: - API

/// 로그인 API 호출 이후, 로직을 진행하기 위한 API 메소드
extension LoginVC {
    
    /// 로그인 API 관련 메소드
    /// - 로그인 성공 시, 토근을 전역변수 `Constant.token` 에 값을 저장한다. 이후 홈 회면으로 이동한다.
    /// - 로그인 실패 시, 실패 이유에 대한 `message`를 UIViewController.view 에 호출한다.
    func didSucceedLogin(_ token: String?, userID: String) {
        // 토큰 전달
        guard let token = token else { return }
        Constant.token = token
        Constant.userID = userID
        
        //FirebaseToken Update
        let fcm_token = (UserDefaults.standard.object(forKey: "fcm_token") as? String) ?? ""
        if !fcm_token.isEmpty {
            EditingProfileDataManager().getUserId(token, fcm_token)
        }
        
        EditingProfileDataManager().getPremiumDateFromAPI(EditingProfileInput(token: Constant.token),
                                                          viewController: self)
        
        
        // 회면전환 - Main Controller 로 이동.
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 로그인 실패했을 때, 경고창을 보여주기 위한 메소드
    func didFaildLogin(_ response: LoginResponse) {
        guard let message = response.message else { return }
        print("DEBUG: 실패이유 = \(message)")
//        alertMessageView.text = "\(message)"
        presentAlert(message: "\(message)")
        
    }
}


// MARK: - 이용기한 남은지 확인하기 위한 API 메소드
extension LoginVC {
    
    func didSuccessNetworing(response: EditingProfileResponse) {
        
//        print("DEBUG: 시작일: \(response.dtPremiumActivate)")
//        print("DEBUG: 종료일: \(response.dtPremiumExpire)")
//        Constant.remainPremiumDateInt = nil
        
        let activateDate: String? = response.dtPremiumActivate
        let expireDate: String? = response.dtPremiumExpire
//        var dateRemainingString: String?
        
        
        guard let startDateString = activateDate else { return }
        guard let expireDateString = expireDate else { return }
        
        Constant.dtPremiumActivate = startDateString
        Constant.dtPremiumExpire = expireDateString
        
//        let startDate = dateStringToDate(startDateString)
//        let endDate = dateStringToDate(expireDateString)
        
//        let dateRemaining = endDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
//        let dayRemaining = dateRemainingCalculate(startDate: startDate, expireDate: endDate)
//        if dateRemaining > 0 {
//            Constant.remainPremiumDateInt = dayRemaining
//        }
    }
}

extension LoginVC {
    func dateRemainingCalculate(startDate: Date, expireDate: Date) -> Int {
        
        let dateRemaining = expireDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let result = Int(dateRemaining / 86400)
        return result
    }
}
