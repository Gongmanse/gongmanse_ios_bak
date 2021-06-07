//
//  MyCalendarCell.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import UIKit

class MyCalendarCell: UITableViewCell {
    
    static let identifier = "MyCalendarCell"
    
    private let calendarTitle: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.font = .appBoldFontWith(size: 14)
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "시작시간"
        label.textAlignment = .left
        label.font = .appBoldFontWith(size: 12)
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        label.text = "종료시간"
        label.textAlignment = .left
        label.font = .appBoldFontWith(size: 12)
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    
    private let startTimeDate: UILabel = {
        let label = UILabel()
        label.text = "2021-04-21 19:44"
        label.font = .appBoldFontWith(size: 12)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let endTimeDate: UILabel = {
        let label = UILabel()
        label.text = "2021-04-21 19:44"
        label.font = .appBoldFontWith(size: 12)
        return label
    }()
    
    lazy var startStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startTimeLabel, startTimeDate])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    lazy var endStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [endTimeLabel, endTimeDate])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    // 가장 상위 스택뷰
    lazy var dateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startStackView, endStackView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 5
        return stack
    }()
    
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        fatalError()
    }
    
    func setUp() {
        
        contentView.addSubview(calendarTitle)
        contentView.addSubview(dateStackView)
        
        calendarTitle.translatesAutoresizingMaskIntoConstraints = false
        calendarTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        calendarTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        calendarTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.topAnchor.constraint(equalTo: calendarTitle.bottomAnchor, constant: 5).isActive = true
        dateStackView.leadingAnchor.constraint(equalTo: calendarTitle.leadingAnchor).isActive = true
        dateStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        dateStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentView.frame.size.width / 3).isActive = true
    }
}
