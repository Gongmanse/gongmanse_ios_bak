import UIKit

class SideMenuVC: UITableViewController {
    
    // MARK: - Properties

    ///목록 데이터 배열
    let titles = ["나의 활동", "나의 일정", "공만세란?", "공지사항", "고객센터", "설정"]
    
    ///아이콘 데이터 배열
    let icons = [
        UIImage(named: "myActivity"),
        UIImage(named: "mySchedule"),
        UIImage(named: "whatSGongmanse"),
        UIImage(named: "notice"),
        UIImage(named: "helpCenter"),
        UIImage(named: "settings")
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Actions

    @objc func handleLoginButton() {
        // TODO: 로그인 이후에는 이용권이 나타날 수 있도록 처리해둘 것
        
        
    }
    

    @objc func handleRegistration() {
        
    }
    

    // MARK: - Helpers
    
    func configureUI() {
        
        // tableView 설정
        tableView.isScrollEnabled = false
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
            
            // test용 다이렉트
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(settingsVC, animated: true)
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0,
                           width: tableView.frame.width,
                           height: 230)
        let headerView = SideMenuHeaderView(frame: frame)
        headerView.delegate = self
//        headerView.passTicketContainerView.anchor(bottom: headerView.bottomAnchor,
//                                                  height: 0)
        headerView.passTicketContainerView.isHidden = true
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 230
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
    
    func clickedRegistrationButton() {
        let vc = RegistrationVC(nibName: "RegistrationVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickedBuyingPassTicketButton() {
        let vc = PassTicketVC(nibName: "PassTicketVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
