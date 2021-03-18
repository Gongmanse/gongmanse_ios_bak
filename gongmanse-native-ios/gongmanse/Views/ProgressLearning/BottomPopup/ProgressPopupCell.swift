//
//  ProgressPopupCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit

class ProgressPopupCell: UITableViewCell {

    //MARK: - Properties
    
    var viewModel : ProgressPopupViewModel? {
        didSet { configure() }
    }
    
    
    @IBOutlet weak var title: UILabel!
  
    
    
    //MARK: - Lifecylce

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    }
    
    //MARK: - Helper functions
    
    func configure() {
        guard let viewModel = viewModel else { return }
        title.text = viewModel.data
    }
    
}
