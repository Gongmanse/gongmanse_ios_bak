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
        text.borderStyle = .roundedRect
        text.autocorrectionType = .no
        text.keyboardType = .default
        text.returnKeyType = .done
        text.setContentHuggingPriority(.defaultLow, for: .horizontal)
        text.placeholder = "질문을 입력해주세요."
        text.backgroundColor = .rgb(red: 237, green: 237, blue: 237)
        text.keyboardType = .default
        text.returnKeyType = .default
        return text
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("전송", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.backgroundColor = .mainOrange
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 10
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
    
    
    // QnA 목록이 없습니다.
    private let lectureQnALabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "강의 Q&A 내용이 없습니다."
        return label
    }()
    
    private let emptyAlert: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "alert")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    //MARK: - Lifecycle
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        
        videoVM.requestVideoQnA(videoID)
        
        emptyStackView.isHidden = true
        tableView.isHidden = false
        
        if videoVM.videoQnAInformation?.data.count == nil || videoVM.videoQnAInformation?.data.count == 0{
            
            emptyStackView.isHidden = false
            tableView.isHidden = true
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // initialize what is needed

        self.backgroundColor = .white
        
        videoVM.reloadDelegate = self
        sendText.delegate = self
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name("keyboardHide"), object: nil)
    }
    
    @objc func keyboardHide(_ sender: Notification) {
        sendText.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let keyboardFame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, isKeyboardSelect == false {
            
            let keyboardRectangle = keyboardFame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            UIView.animate(withDuration: 1) {
                print("Empty == ", self.bottomStackView.frame.origin.y)
                print("bottom == ", self.bottomStackView.frame.origin.y)
                self.emptyStackView.frame.origin.y -= keyboardHeight
                self.bottomStackView.frame.origin.y -= keyboardHeight
            }
            
            isKeyboardSelect = true
            
        }
        NotificationCenter.default.post(name: Notification.Name("1234"), object: nil)
    }
 
    @objc func keyboardWillHide(_ sender: Notification) {
        if let keyboardFame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, isKeyboardSelect == true {
            
            let keyboardRectangle = keyboardFame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            UIView.animate(withDuration: 1) {
                print(self.bottomStackView.frame.origin.y)
                self.emptyStackView.frame.origin.y += keyboardHeight
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
 
    
    
    @objc func textPostButtonAction(_ sender: UIButton) {
        
        if Constant.isLogin {
            if sendText.text != "" {
                videoVM.requestVideoQnAInsert(videoID, content: sendText.text!)
                videoVM.requestVideoQnA(videoID)
                
                sendText.text = ""
                
                sendText.resignFirstResponder()
            }
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }

    }
    
    func scrollToBottom() {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        let short = videoVM.videoQnAInformation?.data[indexPath.row]
        
        print(sideHeaderVM.userID)
        
        if let teacher = short?.sTeacher {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: otherChatIdentifier, for: indexPath) as? QnAOthersChatCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            cell.otherContent.text = "A. \(teacher)\n\(short?.sAnswer ?? "")".htmlEscaped
            
            if let sUrl = short?.sTeacherImg {
                let url = URL(string: "\(fileBaseURL)/\(sUrl)")
                let data = try? Data(contentsOf: url!)
                cell.otherProfile.image = UIImage(data: data!)
                cell.otherProfile.backgroundColor = UIColor.clear
            }
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: myChatIdentifier, for: indexPath) as? QnAMyChatCell else { return UITableViewCell() }

            cell.selectionStyle = .none
            cell.myContent.text = "Q. \(short?.sNickname ?? "")\n\(short?.sQuestion ?? "")"
            
            if let sUrl = short?.sUserImg {
                let url = URL(string: "\(fileBaseURL)/\(sUrl)")
                let data = try? Data(contentsOf: url!)
                cell.myProfile.image = UIImage(data: data!)
                cell.myProfile.backgroundColor = UIColor.clear
            }
            
            return cell
        }
   
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
        contentView.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(lectureQnALabel)
        
        
        bottomStackView.addArrangedSubview(sendText)
        bottomStackView.addArrangedSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        videoVM.reloadDelegate = self
        
        let nib1 = UINib(nibName: myChatIdentifier, bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: myChatIdentifier)
        
        let nib2 = UINib(nibName: otherChatIdentifier, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: otherChatIdentifier)
        
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
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

extension BottomQnACell: TableReloadData {
    
    func reloadTable() {
        
        if videoVM.videoQnAInformation?.data.count != 0 {
            emptyStackView.isHidden = true
            tableView.isHidden = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
        
        
        
    }
}
