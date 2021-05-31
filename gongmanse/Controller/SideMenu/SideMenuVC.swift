import UIKit

class SideMenuVC: UITableViewController {
    
    // MARK: - Properties

    var viewModel = SideMenuHeaderViewModel(token: Constant.token, userID: Constant.userID)
    
    // maybe refactor
    var profileVM = SideMenuHeaderViewModel()
    
    ///목록 데이터 배열
    let titles = ["나의 활동", "나의 일정", "공만세란?", "공지사항", "고객센터", "설정"]
//    let titles = ["공만세란?", "공지사항", "고객센터", "설정"]
    
    ///아이콘 데이터 배열
    let icons = [
        UIImage(named: "myActivity"),
        UIImage(named: "mySchedule"),
        UIImage(named: "whatSGongmanse"),
        UIImage(named: "notice"),
        UIImage(named: "helpCenter"),
        UIImage(named: "settings")
    ]
    
    /// HeaderView 높이
    lazy var headerViewHeight = view.frame.height * 0.31 {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        profileVM.reloadDelegate = self
        profileVM.requestProfileApi(Constant.token)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // viewWillAppear에 로그인 여부 로직을 작성한 이유)
        // 혹시 추후에 sideMenu를 종료한 이후에 sideMenu가 들어가지 않도록 해달라는 요구까지 대응하기 위함이다.
        viewModel.headerViewHeight = view.frame.height
        headerViewHeight = viewModel.isHeaderHeight
        tableView.reloadData()
    }
    
    
    // MARK: - Actions


    // MARK: - Helpers
    
    func configureUI() {
        
        // tableView 설정
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
    }
    
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //테이블 셀 식별자
        let id = "menuCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        //타이틀과 이미지를 대입한다.
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        //폰트 설정
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let myActivityVC = self.storyboard?.instantiateViewController(withIdentifier: "MyActivityVC") as! MyActivityVC
            self.navigationController?.pushViewController(myActivityVC, animated: true)
        } else if indexPath.row == 1 {
            let myCalendarVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCalendarVC") as! MyCalendarVC
            self.navigationController?.pushViewController(myCalendarVC, animated: true)
        } else if indexPath.row == 2 {
            let whatIsGongManseVC = self.storyboard?.instantiateViewController(withIdentifier: "WhatIsGongManseVC") as! WhatIsGongManseVC
            self.navigationController?.pushViewController(whatIsGongManseVC, animated: true)
        } else if indexPath.row == 3 {
            let sideMenuNoticeVC = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuNoticeVC") as! SideMenuNoticeVC
            self.navigationController?.pushViewController(sideMenuNoticeVC, animated: true)
        } else if indexPath.row == 4 {
            let customerServiceVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomerServiceVC") as! CustomerServiceVC
            self.navigationController?.pushViewController(customerServiceVC, animated: true)
        } else if indexPath.row == 5 {
            
//             test용 다이렉트
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(settingsVC, animated: true)
            
//            if indexPath.row == 0 {
//                let whatIsGongManseVC = self.storyboard?.instantiateViewController(withIdentifier: "WhatIsGongManseVC") as! WhatIsGongManseVC
//                self.navigationController?.pushViewController(whatIsGongManseVC, animated: true)
//            } else if indexPath.row == 1 {
//                let sideMenuNoticeVC = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuNoticeVC") as! SideMenuNoticeVC
//                self.navigationController?.pushViewController(sideMenuNoticeVC, animated: true)
//            } else if indexPath.row == 2 {
//                let customerServiceVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomerServiceVC") as! CustomerServiceVC
//                self.navigationController?.pushViewController(customerServiceVC, animated: true)
//            } else if indexPath.row == 3 {
//
//                // test용 다이렉트
//                let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
//                self.navigationController?.pushViewController(settingsVC, animated: true)
            /* *
            로그인 안하면 실행할 코드
            if Constant.token == "" {
                let alert = UIAlertController(title: "로그인", message: "로그인 하시겠습니까?", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "확인", style: .default) { _ in
                    let vc = LoginVC(nibName: "LoginVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }else{
                let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
                self.navigationController?.pushViewController(settingsVC, animated: true)
            }
            */
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = CGRect(x: 0, y: 0,
                           width: Int(tableView.frame.width),
                           height: Int(headerViewHeight))
        let headerView = SideMenuHeaderView(frame: frame)
        headerView.viewModel = viewModel
        // "headerView"에서 UIController을 대신해주기 위해 delegate를 설정한다.
        headerView.sideMenuHeaderViewDelegate = self
        headerView.passTicketContainerView.isHidden = viewModel.isLogin ? false : true
        return headerView
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(headerViewHeight)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section == 0 else { return nil }
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        footerView.isUserInteractionEnabled = true
        let termsOfServiceBtn = UIButton(frame: CGRect(x: 0, y: 310, width: tableView.frame.width / 2, height: 30))
        let privacyPolicyBtn = UIButton(frame: CGRect(x: 157, y: 310, width: tableView.frame.width / 2, height: 30))
        
        termsOfServiceBtn.setTitle("이용약관", for: .normal)
        termsOfServiceBtn.backgroundColor = .systemGray4
        termsOfServiceBtn.tintColor = .white
        termsOfServiceBtn.addTarget(self, action: #selector(showTermsOfService), for: .touchUpInside)
        footerView.addSubview(termsOfServiceBtn)
        termsOfServiceBtn.anchor(top: footerView.topAnchor,
                                 left: footerView.leftAnchor)
        termsOfServiceBtn.setDimensions(height: footerView.frame.height,
                                        width: footerView.frame.width * 0.5)
        
        privacyPolicyBtn.setTitle("개인정보처리방침", for: .normal)
        privacyPolicyBtn.backgroundColor = .systemGray4
        privacyPolicyBtn.tintColor = .white
        privacyPolicyBtn.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        footerView.addSubview(privacyPolicyBtn)
        privacyPolicyBtn.anchor(top: footerView.topAnchor,
                                 right: footerView.rightAnchor)
        privacyPolicyBtn.setDimensions(height: footerView.frame.height,
                                        width: footerView.frame.width * 0.5)
        
        termsOfServiceBtn.translatesAutoresizingMaskIntoConstraints = false
        
        return footerView
    }
    
    @objc func showTermsOfService() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfServiceVC") as! TermsOfServiceVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showPrivacyPolicy() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SideMenuVC: SideMenuHeaderViewDelegate {
    
    func handleDismiss() {
        self.dismiss(animated: true)
    }
    
    func clickedLoginButton() {
        let vc = LoginVC(nibName: "LoginVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickedLogoutButton() {
        Constant.token = ""
        viewModel.token = Constant.token
        headerViewHeight = viewModel.isHeaderHeight
        tableView.reloadData()
    }
    
    func clickedRegistrationButton() {
        let vc = RegistrationVC(nibName: "RegistrationVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickedBuyingPassTicketButton() {
        let vc = PassTicketVC(nibName: "PassTicketVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SideMenuVC: TableReloadData {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
