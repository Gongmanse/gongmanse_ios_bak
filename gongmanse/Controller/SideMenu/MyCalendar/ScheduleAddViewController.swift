//
//  ScheduleAddViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/05/31.
//

enum CalendarState {
    case addCalendar
    case modifyCalendar
}

import UIKit

class ScheduleAddViewController: UIViewController, AlarmListProtocol, PassAllStartDate, PassAllEndDate {
    
    // 나의 일정 Desciption ID
    var calendarId: String?
    
    var calendarState: CalendarState?
    
    // CalendarState == modifyCalendar
    var passedDateModel: CalendarMyDataModel?
    var passedIndexPath: Int?
    // ScheduleAddCell
    let titleText: [String] = ["제목","내용","시간","알림", "반복"]
    
    var registViewModel: CalendarRegistViewModel? = CalendarRegistViewModel()
    
    
    weak var delegateCalendar: CollectionReloadData?
    
    
    // PassAllStartDate
    var allStartDate: String?
    let startFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        formatter.string(from: Date())
        
        return formatter
    }()
    var wholeDayText: String = ""
    
    // PassAllEndDate
    var allEndDate: String?
    let endFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        
        return formatter
    }()
    // AlarmListProtocol
    var alarmTextList: String = ""
    var alarmConvertText: String = ""
    
    var repeatTextLlist: String = ""
    var repeatConvertText: String = ""
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var addCalendarDelegate: CollectionReloadData?
    var addTableListDelegate: TableReloadData?
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorInset = .zero
        table.isUserInteractionEnabled = true
        table.estimatedRowHeight = 50
        table.separatorEffect = .none
        
        table.tableFooterView = UIView()
        return table
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 17)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 15
        return button
    }()
    
    lazy var cellTitleText: String? = nil
    
    lazy var cellContentText: String? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.tableView.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationConfigure()
        configuration()
        constraints()
        
        registerButton.addTarget(self, action: #selector(registerAlarm(_:)), for: .touchUpInside)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(popAction(_:)), name: NSNotification.Name("calendar"), object: nil)
        
        
    }
    
    @objc func popAction(_ sender: Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func registerAlarm(_ sender: UIButton) {
        
        let startString = startFormatter.string(from: Date())
        let endString = endFormatter.string(from: Date(timeIntervalSinceNow: 600))
        
        switch calendarState {
        case .addCalendar:
            
            registViewModel?.requestRegistApi(title: cellTitleText  ?? "",
                                              content: cellContentText ?? "",
                                              wholeDay: wholeDayText,
                                              startDate: allStartDate ?? startString,
                                              endDate: allEndDate ?? endString,
                                              alarm: alarmConvertText,
                                              repeatAlarm: repeatConvertText,
                                              repeatCount: nil)
            
            
            
        case .modifyCalendar:
            
            registViewModel?.requestUpdateApi(updateID: calendarId ?? "",
                                              title: cellTitleText ?? "",
                                              content: cellContentText ?? "",
                                              iswholeDay: wholeDayText,
                                              startDate: allStartDate ?? startString,
                                              endDate: allEndDate ?? endString,
                                              alarm: alarmConvertText,
                                              repeatAlarm: repeatConvertText,
                                              repeatCount: nil)
            
            
            
        default:
            return
        }
       
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tableView.endEditing(true)
        }
    }
    
    @objc func trashNavigationAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "삭제하시겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) { (_) in
            self.registViewModel?.requestDeleteApi(deleteId: self.calendarId ?? "")
            
            self.delegateCalendar?.reloadCollection()
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ScheduleAddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        
        case 0...1:
            return 50
            
        case 2:
            return 130
            
        case 3...4:
            return 50
            
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        
        case 0...1:
            return UITableView.automaticDimension
            
        case 2:
            return 130
            
        case 3...4:
            return 50
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch calendarState {
        case .addCalendar:
            switch indexPath.row {
            
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddCell.identifier, for: indexPath) as? ScheduleAddCell else { return UITableViewCell() }
                
                cell.titleAppear(text: titleText[indexPath.row])
                cell.placeholderAppear(text: "클릭하여 제목을 입력하세요")
                cell.selectionStyle = .none
                
                cell.textChanged { [weak self] text in
                    self?.cellTitleText = text
                    
                    if text != "" {
                        DispatchQueue.main.async {
                            self?.registerButton.isEnabled = true
                            self?.registerButton.backgroundColor = .mainOrange
                        }
                    }else{
                        DispatchQueue.main.async {
                            self?.registerButton.isEnabled = false
                            self?.registerButton.backgroundColor = .lightGray
                        }
                    }
                }
                
                return cell
                
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddCell.identifier, for: indexPath) as? ScheduleAddCell else { return UITableViewCell() }
                
                
                
                cell.titleAppear(text: titleText[indexPath.row])
                cell.placeholderAppear(text: "클릭하여 내용을 입력하세요")
                cell.selectionStyle = .none
                
                cell.textChanged { [weak self] text in
                    self?.cellContentText = text
                }
                
            
                return cell
                
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddTimerCell.identifier, for: indexPath) as? ScheduleAddTimerCell else { return UITableViewCell() }
                
                
                
                cell.timeLabel.text = titleText[indexPath.row]

                registViewModel?.allDaySwitch.bindAndFire(listener: { [weak self] bool in
                    cell.startDateLabel.text = bool ? "하루종일" : self?.registViewModel?.currentStartDate()
                    cell.endDateLabel.text = bool ? "하루종일" : self?.registViewModel?.currentEndDate()
                    self?.wholeDayText = bool ? "1" : "0"
                })
                
                
                cell.startDateLabel.text = allStartDate != nil ? allStartDate : registViewModel?.currentStartDate()
                cell.endDateLabel.text = allEndDate != nil ? allEndDate : registViewModel?.currentEndDate()
                

                
                
                cell.startDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action: #selector(startLabelAction(_:))))
                
                cell.endDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                              action: #selector(endLabelAction(_:))))
                
                cell.allDaySwitch.addTarget(self, action: #selector(isValueChangedSwitch(_:)), for: .valueChanged)
                
                cell.selectionStyle = .none
                return cell
                
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
                
                
                cell.alarmSelectLabel.text = "없음"
                
                if alarmTextList != "" {
                    cell.alarmSelectLabel.text = alarmTextList
                }
                
                cell.alarmTextLabel.text = titleText[indexPath.row]
                cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action:               #selector(alarmList(_:))))
                
                cell.selectionStyle = .none
                return cell
                
            case 4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
                
                cell.alarmSelectLabel.text = "없음"
                
                if repeatTextLlist != "" {
                    cell.alarmSelectLabel.text = repeatTextLlist
                }
                
                cell.alarmTextLabel.text = titleText[indexPath.row]
                cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action:               #selector(repeatList(_:))))
                
                cell.selectionStyle = .none
                return cell
                
            default:
                return UITableViewCell()
            }
            
        case .modifyCalendar:
            guard let modifyIndexPath = passedIndexPath else { return UITableViewCell() }
            switch indexPath.row {
            
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddCell.identifier, for: indexPath) as? ScheduleAddCell else { return UITableViewCell() }
                
                cell.titleAppear(text: titleText[indexPath.row])
                cell.placeholderAppear(text: "클릭하여 제목을 입력하세요")
                cell.contentAppear(text: passedDateModel?.description[modifyIndexPath].sTitle ?? "")
                
                cell.textChanged { [weak self] text in
                    self?.cellTitleText = text
                }
                cell.selectionStyle = .none
            
                return cell
                
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddCell.identifier, for: indexPath) as? ScheduleAddCell else { return UITableViewCell() }
                
                cell.titleAppear(text: titleText[indexPath.row])
                cell.placeholderAppear(text: "클릭하여 내용을 입력하세요")
                cell.contentAppear(text: passedDateModel?.description[modifyIndexPath].sDescription ?? "")
                
                cell.textChanged { [weak self] text in
                    self?.cellContentText = text
                }
                cell.selectionStyle = .none
            
                return cell
                
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddTimerCell.identifier, for: indexPath) as? ScheduleAddTimerCell else { return UITableViewCell() }
                
                cell.timeLabel.text = titleText[indexPath.row]
                
                registViewModel?.allDaySwitch.bindAndFire(listener: { [weak self] bool in
                    cell.startDateLabel.text = bool ? "하루종일" : self?.registViewModel?.currentStartDate()
                    cell.endDateLabel.text = bool ? "하루종일" : self?.registViewModel?.currentEndDate()
                    self?.wholeDayText = bool ? "1" : "0"
                })
                
                cell.startDateLabel.text = allStartDate != nil ? allStartDate : registViewModel?.currentStartDate()
                cell.endDateLabel.text = allEndDate != nil ? allEndDate : registViewModel?.currentEndDate()
                
                cell.startDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action: #selector(startLabelAction(_:))))
                
                cell.endDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                              action: #selector(endLabelAction(_:))))
                
                cell.allDaySwitch.addTarget(self, action: #selector(isValueChangedSwitch(_:)), for: .valueChanged)
                
                cell.selectionStyle = .none
                return cell
                
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
                
                
                cell.alarmSelectLabel.text = passedDateModel?.description[modifyIndexPath].alarmCode ?? "없음"
                
                if alarmTextList != "" {
                    cell.alarmSelectLabel.text = alarmTextList
                }
                
                cell.alarmTextLabel.text = titleText[indexPath.row]
                cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action:               #selector(alarmList(_:))))
                
                cell.selectionStyle = .none
                return cell
                
            case 4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
                
                cell.alarmSelectLabel.text = passedDateModel?.description[modifyIndexPath].repeatCode ?? "없음"
                
                if repeatTextLlist != "" {
                    cell.alarmSelectLabel.text = repeatTextLlist
                }
                
                cell.alarmTextLabel.text = titleText[indexPath.row]
                cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                action:               #selector(repeatList(_:))))
                
                cell.selectionStyle = .none
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    // Switch 누를때 호출 메소드
    @objc func isValueChangedSwitch(_ sender: UISwitch) {
        // databinding 해보기
        registViewModel?.allDaySwitch.value = sender.isOn
    }
    
    // indexPath 2 - 1
    @objc func startLabelAction(_ sender: UITapGestureRecognizer) {
        let startDateVC = StartLabelPickerViewController()
        startDateVC.allStartDelegate = self
        self.present(startDateVC, animated: true, completion: nil)
    }
    
    // indexPath 2 - 2
    @objc func endLabelAction(_ sender: UITapGestureRecognizer) {
        let endDateVC = EndLabelPickerViewController()
        endDateVC.allEndDelegate = self
        self.present(endDateVC, animated: true, completion: nil)
    }
    
    
    // indexPath 3
    @objc func alarmList(_ sender: UITapGestureRecognizer) {
        let vc = AlramRelationListViewController()
        vc.alarmState = .Alram
        vc.registViewModel = registViewModel
        vc.alarmDelegate = self
        self.present(vc, animated: true, completion: nil)

    }
    // indexPath 4
    @objc func repeatList(_ sender: UITapGestureRecognizer) {
        let vc = AlramRelationListViewController()
        vc.alarmDelegate = self
        vc.registViewModel = registViewModel
        vc.alarmState = .Repeat
        self.present(vc, animated: true, completion: nil)
    }
    
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
}

extension ScheduleAddViewController {
    
    func navigationConfigure() {
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "일정 등록"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        
    }
    
    

    func configuration() {
        
        view.addSubview(tableView)
        view.addSubview(registerButton)
        
        tableView.register(ScheduleAddCell.self, forCellReuseIdentifier: ScheduleAddCell.identifier)
        tableView.register(ScheduleAddTimerCell.self, forCellReuseIdentifier: ScheduleAddTimerCell.identifier)
        tableView.register(ScheduleAddAlarmCell.self, forCellReuseIdentifier: ScheduleAddAlarmCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                            target: self,
                                                            action: #selector(trashNavigationAction(_:)))
        
        switch calendarState {
        case .addCalendar:
            registerButton.setTitle("등록하기", for: .normal)
            registerButton.isEnabled = false
            registerButton.backgroundColor = .lightGray
            
            navigationItem.rightBarButtonItem = nil
            
        case .modifyCalendar:
            registerButton.setTitle("수정하기", for: .normal)
            
        default:
            return
        }
        
    }
    
    func constraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.size.height / 2).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
}
