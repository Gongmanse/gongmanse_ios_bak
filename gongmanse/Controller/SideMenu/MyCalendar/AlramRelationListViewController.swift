//
//  AlramRelationListViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/06/01.
//

import UIKit
import BottomPopup

enum AlarmListState {
    case Alram
    case Repeat
}

protocol AlarmListProtocol: AnyObject {
    var alarmTextList: String { get set }
    var alarmConvertText: String { get set }
    
    var repeatTextLlist: String { get set }
    var repeatConvertText: String { get set }
    
    func reloadTable()
}


// ------
class AlramRelationListViewController: BottomPopupViewController {

    // Enum
    var alarmState: AlarmListState?
    
    var registViewModel: CalendarRegistViewModel?
    // Protocol
    var alarmDelegate: AlarmListProtocol?
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorInset = .zero
        table.isUserInteractionEnabled = true
        return table
    }()
    
    
    // topView
    let topLittleImage: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let topTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let topDismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "largeX"), for: .normal)
        return button
    }()
    
    let topOrangeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLittleImage, topTextLabel, topDismissButton])
        stack.backgroundColor = .white
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    let alarmListTextArray: [String] = ["없음", "정시", "10분 전", "30분 전", "1시간 전", "3시간 전", "12시간 전", "1일 전","1주 전"]
    
    let repeatListTextArray: [String] = ["없음", "매일", "매주", "매달", "매년"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTopView()
        configuration()
        constraints()
        
        topDismissButton.addTarget(self, action: #selector(dismissActive(_:)), for: .touchUpInside)
    }
    
    @objc func dismissActive(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpTopView() {
        switch alarmState {
        case .Alram:
            topLittleImage.image = UIImage(named: "timeline")
            topTextLabel.text = "알림"
            
        case .Repeat:
            topLittleImage.image = UIImage(named: "timeline")
            topTextLabel.text = "반복"
            
        case .none:
            return
        }
    }
}

// MARK: - TableView

extension AlramRelationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch alarmState {
        
        case .Alram:
            return alarmListTextArray.count
            
        case .Repeat:
            return repeatListTextArray.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch alarmState {
        
        case .Alram:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmListCell.identifier, for: indexPath) as? AlarmListCell else { return UITableViewCell() }
            
            cell.textLabel?.text = alarmListTextArray[indexPath.row]
            return cell
            
        case .Repeat:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmListCell.identifier, for: indexPath) as? AlarmListCell else { return UITableViewCell() }
            
            cell.textLabel?.text = repeatListTextArray[indexPath.row]
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch alarmState {
        case .Alram:
            
            let selectAlarmText = alarmListTextArray[indexPath.row]
            
            alarmDelegate?.alarmTextList = selectAlarmText
            alarmDelegate?.alarmConvertText = registViewModel?.alarmConvertString(selectAlarmText) ?? ""
            alarmDelegate?.reloadTable()
            
            self.dismiss(animated: true, completion: nil)
            
        case .Repeat:
            
            let selectRepeatText = repeatListTextArray[indexPath.row]
            
            alarmDelegate?.repeatTextLlist = selectRepeatText
            alarmDelegate?.repeatConvertText = registViewModel?.repeatConvertString(selectRepeatText) ?? ""
            alarmDelegate?.reloadTable()
            
            self.dismiss(animated: true, completion: nil)

        default:
            return
        }
    }
}

// MARK: - UI

extension AlramRelationListViewController {
    
    func configuration() {
        
        
        view.addSubview(tableView)
        view.addSubview(topStackView)
        view.addSubview(topOrangeLineView)
        
        tableView.register(AlarmListCell.self, forCellReuseIdentifier: AlarmListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func constraints() {
        
        
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        topOrangeLineView.translatesAutoresizingMaskIntoConstraints = false
        topOrangeLineView.topAnchor.constraint(equalTo: topStackView.bottomAnchor).isActive = true
        topOrangeLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topOrangeLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topOrangeLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topOrangeLineView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

class AlarmListCell: UITableViewCell {
    
    static let identifier = "AlarmListCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
