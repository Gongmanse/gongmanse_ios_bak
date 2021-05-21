import UIKit
import BottomPopup

class SettingsVC: UIViewController, BottomPopupDelegate {
    
    private var tableView = UITableView()
    private let PushAlertCellIdentifier = "PushAlertCell"
    //private let configurationList: [String] = ["기본 학년 선택", "기본 과목 선택", "자막 적용", "모바일 데이터 허용", "푸시 알림"]
    private let configurationList: [String] = ["기본 학년 선택", "기본 과목 선택"]
    
    var dataApi: SubjectGetDataModel?
    
    var height: CGFloat = 300
       
    var presentDuration: Double = 0.2
       
    var dismissDuration: Double = 0.5
    
    private var gradeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 18)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("모든 학년", for: .normal)
        button.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        return button
    }()
    
    private var subjectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 18)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("모든 과목", for: .normal)
        button.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        return button
    }()
    
    private var userToken: String?
    private var filterVM: FilteringViewModel? = FilteringViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Constant.token != "" {
            userToken = Constant.token
        }
        
        
        let testGetFilter = getFilteringAPI()
        testGetFilter.getFilteringData { [weak self] result in
            self?.dataApi = result
            DispatchQueue.main.async {
                let allGrade = "모든 학년"
                self?.gradeButton.setTitle(self?.dataApi?.sGrade == "" ? allGrade : self?.dataApi?.sGrade, for: .normal)

                let allSubject = "모든 과목"
                self?.subjectButton.setTitle(self?.dataApi?.sName == nil ? allSubject : self?.dataApi?.sName, for: .normal)
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationSetting()
        setTableView()
        
        print(Constant.token)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(gradeNoti(_:)), name: NSNotification.Name("gradeFilterText"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subjectNoti(_:)), name: NSNotification.Name("subjectFilterText"), object: nil)
    }
    
    @objc func gradeNoti(_ sender: NotificationCenter) {
        let gradeButtonTitle = UserDefaults.standard.object(forKey: "gradeFilterText")
        gradeButton.setTitle(gradeButtonTitle as? String, for: .normal)

    }
    
    @objc func subjectNoti(_ sender: NotificationCenter) {
        let subjectButtonTitle = UserDefaults.standard.object(forKey: "subjectFilterText")
        subjectButton.setTitle(subjectButtonTitle as? String, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        filterVM?.postData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        filterVM = nil
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
    
    
    
    @objc func presentFilterGradeList(_ sender: UIButton) {
        
        
        let popupvc = FilteringGradePopUpVC()
        popupvc.height = height
        popupvc.presentDuration = presentDuration
        popupvc.dismissDuration = dismissDuration
        popupvc.popupDelegate = self
        self.present(popupvc, animated: true)
    }
    
    @objc func presentFilterSubjectList(_ sender: UIButton) {
        
        let popupvc = FilteringSubjectPopUpVC()
        popupvc.height = height
        popupvc.presentDuration = presentDuration
        popupvc.dismissDuration = dismissDuration
        popupvc.popupDelegate = self
        self.present(popupvc, animated: true)
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
        
        
        
        if 2...4 ~= section {
            
            let switchControl = UISwitch(frame: CGRect(x: 0, y: 0, width: 35, height: 16))
            switchControl.isOn = true
            switchControl.isEnabled = true
            switchControl.onTintColor = UIColor.rgb(red: 237, green: 118, blue: 0)
            headerView.addSubview(switchControl)
            
            switchControl.translatesAutoresizingMaskIntoConstraints = false
            switchControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
            switchControl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            
        }
        
        if section == 0 {
            
            gradeButton.addTarget(self, action: #selector(presentFilterGradeList(_:)), for: .touchUpInside)
            headerView.addSubview(gradeButton)
            
            gradeButton.translatesAutoresizingMaskIntoConstraints = false
            gradeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
            gradeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        }
        
        if section == 1 {
            
            subjectButton.addTarget(self, action: #selector(presentFilterSubjectList(_:)), for: .touchUpInside)
            headerView.addSubview(subjectButton)
            
            subjectButton.translatesAutoresizingMaskIntoConstraints = false
            subjectButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
            subjectButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
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
