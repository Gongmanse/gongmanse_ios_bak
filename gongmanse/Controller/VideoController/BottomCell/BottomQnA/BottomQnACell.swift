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
    
    
    let videoVM = VideoQnAVideModel()
    let sideHeaderVM = SideMenuHeaderViewModel()
    
    lazy var videoID: String = ""

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
    
    var isKeyboardSelect = false
    
    //MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        videoVM.requestVideoQnA(videoID)
        videoVM.reloadDelegate = self
        sendText.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // initialize what is needed

        self.backgroundColor = .white
        
        configuration()
        constraints()
        contentView.isUserInteractionEnabled = true
        
        sendButton.addTarget(self, action: #selector(textPostButtonAction(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        contentView.backgroundColor = .blue
        tableView.backgroundColor = .orange
//        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
//                                                                     action: #selector(endKeyboard)))
    }
    
    @objc func endKeyboard() {
        sendText.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let keyboardFame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, isKeyboardSelect == false {
            
            let keyboardRectangle = keyboardFame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            UIView.animate(withDuration: 1) {
                print(self.bottomStackView.frame.origin.y)
                self.bottomStackView.frame.origin.y -= keyboardHeight
            }
            
            isKeyboardSelect = true
        }
    }
 
    @objc func keyboardWillHide(_ sender: Notification) {
        if let keyboardFame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, isKeyboardSelect == true {
            
            let keyboardRectangle = keyboardFame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            UIView.animate(withDuration: 1) {
                print(self.bottomStackView.frame.origin.y)
                self.bottomStackView.frame.origin.y += keyboardHeight
            }
            
            isKeyboardSelect = false
        }
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
    
    
    @objc func textPostButtonAction(_ sender: UIButton) {
        
        if sendText.text != "" {
            videoVM.requestVideoQnAInsert(videoID, content: sendText.text!)
            videoVM.requestVideoQnA(videoID)
        }
        
    }
    
}

extension BottomQnACell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension BottomQnACell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoVM.videoQnAInformation?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mynickName = sideHeaderVM.userID
        let qnaNickName = videoVM.videoQnAInformation?.data[indexPath.row].sNickname
        print(qnaNickName)
        print(mynickName)
        print(sideHeaderVM.userID)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: otherChatIdentifier, for: indexPath) as? QnAOthersChatCell else { return UITableViewCell() }
        
        let short = videoVM.videoQnAInformation?.data[indexPath.row]
        
        
        cell.selectionStyle = .none
        cell.otherContent.text = "A. \(short?.sNickname ?? "")\n\(short?.sQuestion ?? "")"
        return cell
    }

}

extension BottomQnACell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText.resignFirstResponder()
        return true
    }
}
extension BottomQnACell {
    
    func configuration() {
        
        contentView.addSubview(tableView)
        contentView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(sendText)
        bottomStackView.addArrangedSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        videoVM.reloadDelegate = self
        tableView.register(QnAMyChatCell.self, forCellReuseIdentifier: myChatIdentifier)
        
        let nib = UINib(nibName: otherChatIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: otherChatIdentifier)
        
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

extension BottomQnACell: TableReloadData {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
