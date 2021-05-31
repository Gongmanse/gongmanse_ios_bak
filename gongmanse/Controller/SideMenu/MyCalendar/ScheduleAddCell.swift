//
//  ScheduleAddCell.swift
//  gongmanse
//
//  Created by wallter on 2021/05/31.
//

import UIKit

class ScheduleAddCell: UITableViewCell {
    
    static let identifier = "ScheduleAddCell"
    
    private let titleLabels: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        return label
    }()
    
    private let subLabels: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func cellAppear() {
        
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

class ScheduleAddTimerCell: UITableViewCell {
    
    static let identifier = "ScheduleAddTimerCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 16)
        return label
    }()
    
    private let startTime: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 13)
        return label
    }()
    
    private let endTime: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 13)
        return label
    }()
    
    lazy var timeStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, startTime, endTime])
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.distribution = .fillEqually
        
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
        
        contentView.addSubview(timeStackView)
        
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        timeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        timeStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
    }
}
