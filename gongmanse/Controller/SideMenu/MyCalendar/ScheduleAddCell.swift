//
//  ScheduleAddCell.swift
//  gongmanse
//
//  Created by wallter on 2021/05/31.
//

import UIKit

// indexPath 0,1 Cell
class ScheduleAddCell: UITableViewCell {
    
    static let identifier = "ScheduleAddCell"
    
    private let titleLabels: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        return label
    }()
    
    private let subLabels: UITextView = {
        let textview = UITextView()
        textview.textAlignment = .justified
        textview.font = .systemFont(ofSize: 16)
        return textview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        	
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func titleAppear(text: String) {
        titleLabels.text = text
    }
    
    
    func setUp() {
        
        contentView.addSubview(titleLabels)
        contentView.addSubview(subLabels)
        
        titleLabels.translatesAutoresizingMaskIntoConstraints = false
        titleLabels.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabels.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        
        subLabels.translatesAutoresizingMaskIntoConstraints = false
        subLabels.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        subLabels.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
}

// indexPath 2 Cell
class ScheduleAddTimerCell: UITableViewCell {
    
    static let identifier = "ScheduleAddTimerCell"
    
    // 시간
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        label.setContentHuggingPriority(.defaultLow-1, for: .horizontal)
        return label
    }()
    
    let allDayLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 14)
        label.text = "하루종일"
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        return label
    }()
    
    let allDaySwitch: UISwitch = {
        let witch = UISwitch()
        witch.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        witch.isOn = false
        return witch
    }()
    
    lazy var timeLabelStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, allDayLabel, allDaySwitch])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        
        return stack
    }()
    //
    
    // 시작
    let startTime: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 13)
        label.text = "시작"
        return label
    }()
    
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "2021.05.31 (목) 15:10"
        return label
    }()
    
    lazy var startStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startTime, startDateLabel])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    //
    
    // 종료
    let endTime: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 13)
        label.text = "종료"
        label.setContentHuggingPriority(.defaultLow-1, for: .horizontal)
        return label
    }()
    
    let endDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "2021.05.31 (목) 15:10"
        return label
    }()
    
    lazy var endStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [endTime, endDateLabel])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    //
    
    // 총괄
    lazy var allStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabelStackView, startStackView, endStackView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        
        contentView.addSubview(timeLabelStackView)
        contentView.addSubview(startStackView)
        contentView.addSubview(endStackView)
        
        timeLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        timeLabelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        timeLabelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        timeLabelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
        startStackView.translatesAutoresizingMaskIntoConstraints = false
        startStackView.topAnchor.constraint(equalTo: timeLabelStackView.bottomAnchor, constant: 15).isActive = true
        startStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27).isActive = true
        startStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
        endStackView.translatesAutoresizingMaskIntoConstraints = false
        endStackView.topAnchor.constraint(equalTo: startStackView.bottomAnchor, constant: 15).isActive = true
        endStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27).isActive = true
        endStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
    }
}

// indexPath 3,4 Cell
class ScheduleAddAlarmCell: UITableViewCell {
    
    static let identifier = "ScheduleAddAlarmCell"
    
    let alarmTextLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        return label
    }()
    
    let alarmSelectLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        label.isUserInteractionEnabled = true
        label.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        
        contentView.addSubview(alarmTextLabel)
        contentView.addSubview(alarmSelectLabel)
        
        alarmTextLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        alarmTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        alarmSelectLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmSelectLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        alarmSelectLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
}

