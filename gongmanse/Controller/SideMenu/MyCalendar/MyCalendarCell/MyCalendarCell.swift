//
//  MyCalendarCell.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import UIKit

class MyCalendarCell: UITableViewCell {
    
    static let identifier = "MyCalendarCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        fatalError()
    }
}
