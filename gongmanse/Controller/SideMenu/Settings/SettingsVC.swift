import UIKit

class SettingsVC: UIViewController {
    
    var tableView = UITableView()
    let PushAlertCellIdentifier = "PushAlertCell"
    let configurationList: [String] = ["기본 학년 선택", "기본 과목 선택", "자막 적용", "모바일 데이터 허용", "푸시 알림"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationSetting()
        setTableView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - UI Setting

extension SettingsVC {
    
    func navigationSetting() {
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "설정"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                
    }
    @objc func presentFilterList(_ sender: UIButton) {
        
    }
}

extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return configurationList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        let configurationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        configurationLabel.font = UIFont(name: "NanumSquareRoundB", size: 16)
        configurationLabel.text = configurationList[section]
        
        
        
        if section == 2 || section == 3 || section == 4{
            print(section)
            let switchControl = UISwitch(frame: CGRect(x: 0, y: 0, width: 35, height: 16))
            switchControl.isOn = true
            switchControl.isEnabled = true
            switchControl.onTintColor = UIColor.rgb(red: 237, green: 118, blue: 0)
            headerView.addSubview(switchControl)
            
            switchControl.translatesAutoresizingMaskIntoConstraints = false
            switchControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
            switchControl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            
        }
        
        if section == 0 || section == 1 {
            
            let gradeButton = UIButton(type: .custom)
            gradeButton.frame = CGRect(x: 0, y: 0, width: 60, height: 18)
            gradeButton.setTitleColor(UIColor.black, for: .normal)
            gradeButton.setTitle("모든 학년", for: .normal)
            gradeButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
            gradeButton.addTarget(self, action: #selector(presentFilterList(_:)), for: .touchUpInside)
            headerView.addSubview(gradeButton)
            
            gradeButton.translatesAutoresizingMaskIntoConstraints = false
            gradeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
            gradeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        }
        
        headerView.addSubview(configurationLabel)
        tableView.addSubview(headerView)
        
                
        configurationLabel.translatesAutoresizingMaskIntoConstraints = false
        configurationLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        configurationLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        configurationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true

        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 2))
        
        footerView.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        tableView.addSubview(footerView)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PushAlertCellIdentifier, for: indexPath) as? PushAlertCell else { return UITableViewCell() }
        
        return cell
    }
}
