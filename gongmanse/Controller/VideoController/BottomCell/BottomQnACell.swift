/*
 하단 Cell 중 "강의 QnA" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class BottomQnACell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "강의 QnA"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 40)
        return label
    }()

    private let chatIdentifier = "QnAMyChatCell"
    
    private let tableView: UITableView = {
         let table = UITableView()
        return table
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // initialize what is needed
        self.addSubview(label)
        self.backgroundColor = .white
        label.centerX(inView: self)
        label.centerY(inView: self)
        
        configuration()
        constraints()
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
        self.isUserInteractionEnabled = true
       // initialize what is needed
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
       // initialize what is needed
    }
    
    func configuration() {
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QnAMyChatCell.self, forCellReuseIdentifier: chatIdentifier)
    }
    
    func constraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

extension BottomQnACell: UITableViewDelegate {
    
}

extension BottomQnACell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: chatIdentifier, for: indexPath) as? QnAMyChatCell else { return UITableViewCell() }
        cell.textLabel?.text = "A"
        return cell
    }
}

class BottomQnAChatCell: UITableViewCell {
    
}
