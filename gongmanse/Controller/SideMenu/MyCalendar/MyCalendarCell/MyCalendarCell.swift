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
        label.font = .appBoldFontWith(size: 14)
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 12)
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 12)
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        return label
    }()
    
    private let startTimeDate: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 12)
        return label
    }()
    
    private let endTimeDate: UILabel = {
        let label = UILabel()
        label.font = .appBoldFontWith(size: 12)
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        fatalError()
    }
    
    
}
