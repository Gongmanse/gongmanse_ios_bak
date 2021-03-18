//
//  RecentKeywordCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

protocol RecentKeywordCellDelegate: class {
    func deleteCell(indexPath: IndexPath)
}


class RecentKeywordCell: UITableViewCell {

    //MARK: - Properties
    
    weak var delegate: RecentKeywordCellDelegate?
    
    var viewModel: RecentKeywordViewModel? {
        didSet { configure() }
    }
    
    
    @IBOutlet weak var keyword: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        

    // Cell 여백 추가 메소드
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    //MARK: - Actions
    
    @IBAction func handleDeleteBtn(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        delegate?.deleteCell(indexPath: viewModel.indexPath)
        print("DEBUG: clicked cell is \(viewModel.indexPath.row)")
    }
    
    
    //MARK: - Helper functions
    
    func configure() {
        guard let viewModel = viewModel else { return }
        keyword.text = viewModel.keyword
        date.text = viewModel.date
    }
    
}
