//
//  PopularKeywordCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

class PopularKeywordCell: UITableViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var keywordNumber: UIImageView!
    @IBOutlet weak var keyword: UILabel!
    var numbering: Int?
    
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    //MARK: - Helper functions
    
    // Cell 여백 추가 메소드
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
}
