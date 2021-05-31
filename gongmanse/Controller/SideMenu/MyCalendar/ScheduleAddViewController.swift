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
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        navigationConfigure()
        configuration()
        constraints()
    }
}

extension ScheduleAddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            
            return cell
            
        case 3...4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAddAlarmCell.identifier, for: indexPath) as? ScheduleAddAlarmCell else { return UITableViewCell() }
            
            cell.alarmSelectLabel.text = "없음"
            cell.alarmTextLabel.text = titleText[indexPath.row]
            
            return cell
            
        default:
            return UITableViewCell()
        }
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
        
        tableView.register(ScheduleAddCell.self, forCellReuseIdentifier: ScheduleAddCell.identifier)
        tableView.register(ScheduleAddTimerCell.self, forCellReuseIdentifier: ScheduleAddTimerCell.identifier)
        tableView.register(ScheduleAddAlarmCell.self, forCellReuseIdentifier: ScheduleAddAlarmCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func constraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
}
