import UIKit

class SideMenuVC: UITableViewController {
    
    //프로필 이미지
    let profileImage = UIImageView()
    //로그인 상태
    let nickName = UILabel()
    //로그인 설명
    let membershipLevel = UILabel()
    //로그인 버튼
    let loginBtn = UIButton()
    //회원가입 버튼
    let signUpBtn = UIButton()
    //닫기 버튼
    let closeBtn = UIButton()
    
    //목록 데이터 배열
    let titles = ["나의 활동", "나의 일정", "공만세란?", "공지사항", "고객센터", "설정"]
    
    //아이콘 데이터 배열
    let icons = [
        UIImage(named: "myActivity.png"),
        UIImage(named: "mySchedule.png"),
        UIImage(named: "whatSGongmanse.png"),
        UIImage(named: "notice.png"),
        UIImage(named: "helpCenter.png"),
        UIImage(named: "settings.png")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        //테이블 뷰의 헤더 역할을 할 뷰를 정의
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 270))
        headerView.backgroundColor = .white
        
        //테이블 뷰의 헤더 뷰로 지정
        self.tableView.tableHeaderView = headerView
        
        //프로필 이미지 설정
        //self.profileImage.image = UIImage(named: "logoIconGray.png")
        self.profileImage.frame = CGRect(x: 118, y: 37, width: 94, height: 94) //위치와 크기를 정의
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2) //반원 형태로 라운딩
        self.profileImage.layer.borderWidth = 0 //border 두께 0 으로
        self.profileImage.layer.masksToBounds = true //마스크 효과
        self.profileImage.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        self.profileImage.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.profileImage.layer.shadowOpacity = 2.0
        self.profileImage.layer.shadowRadius = 5
        self.profileImage.layer.shadowColor = UIColor.gray.cgColor
        self.profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        //헤더 뷰에 추가
        view.addSubview(self.profileImage)
        
        //로그인 상태
        self.nickName.text = "로그인을 해주세요." //label text 내용
        self.nickName.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1) //label text 색상
        self.nickName.frame = CGRect(x: 98, y: 150, width: 150, height: 30) //위치와 크기를 정의
        self.nickName.font = UIFont.systemFont(ofSize: 18) //폰트 사이즈
        self.nickName.backgroundColor = .clear //배경 색상
        
        //헤더 뷰에 추가
        view.addSubview(self.nickName)
        
        //로그인 설명
        self.membershipLevel.text = "로그인하고 더 많은 서비스를 누리세요." //label text 내용
        self.membershipLevel.textColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1) //label text 색상
        self.membershipLevel.frame = CGRect(x: 68, y: 173, width: 250, height: 30) //위치와 크기를 정의
        self.membershipLevel.font = UIFont.systemFont(ofSize: 13) //폰트 사이즈
        self.membershipLevel.backgroundColor = .clear //배경 색상
        
        //헤더 뷰에 추가
        view.addSubview(self.membershipLevel)
        
        //로그인 버튼
        self.loginBtn.setTitle("로그인", for: .normal)
        self.loginBtn.setTitleColor(.white, for: .normal)
        self.loginBtn.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        self.loginBtn.frame = CGRect(x: 51, y: 209, width: 105, height: 35)
        self.loginBtn.layer.cornerRadius = 10
        self.loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        view.addSubview(self.loginBtn)
        self.loginBtn.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        
        //회원가입 버튼
        self.signUpBtn.setTitle("회원가입", for: .normal)
        self.signUpBtn.setTitleColor(.white, for: .normal)
        self.signUpBtn.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        self.signUpBtn.frame = CGRect(x: 173, y: 209, width: 105, height: 35)
        self.signUpBtn.layer.cornerRadius = 10
        self.signUpBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.signUpBtn.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        view.addSubview(self.signUpBtn)
        
        //닫기 버튼
        self.closeBtn.setImage(UIImage(named: "largeX"), for: .normal)
        self.closeBtn.frame = CGRect(x: 270, y: 15, width: 30, height: 30)
        self.closeBtn.backgroundColor = .clear
        
        view.addSubview(self.closeBtn)
        
        headerView.layer.addBorder([.bottom], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        self.closeBtn.addTarget(self, action: #selector(closeButton), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    
    @objc func closeButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLoginButton() {
        // TODO: 로그인 이후에는 이용권이 나타날 수 있도록 처리해둘 것
//        let vc = PassTicketVC(nibName: "PassTicketVC", bundle: nil)
        let vc = LoginVC(nibName: "LoginVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    @objc func handleRegistration() {
        let vc = RegistrationVC(nibName: "RegistrationVC", bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)
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
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}

