/*
 하단 Cell 중 "강의 QnA" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit
enum QnAChat {
    case me, others
    
    var chatState: UITableViewCell {
        switch self {
        case .me:
            return QnAMyChatCell()
        case .others:
            return QnAOthersChatCell()
        }
    }
}

class BottomQnACell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "강의 QnA"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.appBoldFontWith(size: 40)
        return label
    }()

    private let myChatIdentifier = "QnAMyChatCell"
    private let otherChatIdentifier = "QnAOthersChatCell"
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        return table
    }()
    
    private let sendText: UITextField = {
        let text = UITextField()
        text.backgroundColor = .lightGray
        text.borderStyle = .roundedRect
        text.autocorrectionType = .no
        text.keyboardType = .default
        text.returnKeyType = .done
        text.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return text
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("전송", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.backgroundColor = .mainOrange
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
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
        contentView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(sendText)
        bottomStackView.addArrangedSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QnAMyChatCell.self, forCellReuseIdentifier: myChatIdentifier)
        tableView.register(QnAOthersChatCell.self, forCellReuseIdentifier: otherChatIdentifier)
    }
    
    func constraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: sendText.topAnchor).isActive = true
        
        // 하단 스택뷰
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        bottomStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        // 전송 버튼 width == 60
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

extension BottomQnACell: UITableViewDelegate {
    
}

extension BottomQnACell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: myChatIdentifier, for: indexPath) as? QnAMyChatCell else { return UITableViewCell() }
        cell.textLabel?.text = "A"
        return cell
    }
}
