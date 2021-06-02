//
//  ScheduleAddViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/05/31.
//

import UIKit

class ScheduleAddViewController: UIViewController {
    
    // ScheduleAddCell
    let titleText: [String] = ["제목","내용","시간","알림", "반복"]
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorInset = .zero
        table.isUserInteractionEnabled = true
        table.estimatedRowHeight = 50
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        navigationConfigure()
        configuration()
        constraints()
        
        registerButton.addTarget(self, action: #selector(registerAlarm(_:)), for: .touchUpInside)
    }
    
    @objc func registerAlarm(_ sender: UIButton) {
        print("A")
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
        switch indexPath.row {
        
        case 0...1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddCell.identifier, for: indexPath) as? ScheduleAddCell else { return UITableViewCell() }
            
            cell.titleAppear(text: titleText[indexPath.row])
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddTimerCell.identifier, for: indexPath) as? ScheduleAddTimerCell else { return UITableViewCell() }
            
            cell.timeLabel.text = titleText[indexPath.row]
//            cell.startDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector))
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
            
            cell.alarmSelectLabel.text = "없음"
            cell.alarmTextLabel.text = titleText[indexPath.row]
            cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                            action:               #selector(alarmList(_:))))
            return cell
            
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
            
            cell.alarmSelectLabel.text = "없음"
            cell.alarmTextLabel.text = titleText[indexPath.row]
            cell.alarmSelectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                            action:               #selector(repeatList(_:))))
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    // indexPath 2 - 1
    @objc func startLabelAction(_ sender: UITapGestureRecognizer) {
        
    }
    
    // indexPath 3
    @objc func alarmList(_ sender: UITapGestureRecognizer) {
        let vc = AlramRelationListViewController()
        vc.alramState = .Alram
        self.present(vc, animated: true, completion: nil)

    }
    // indexPath 4
    @objc func repeatList(_ sender: UITapGestureRecognizer) {
        let vc = AlramRelationListViewController()
        vc.alramState = .Repeat
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
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