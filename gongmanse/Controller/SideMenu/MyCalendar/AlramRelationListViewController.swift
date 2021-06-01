//
//  AlramRelationListViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/06/01.
//

import UIKit
import BottomPopup

enum AlramListState {
    case Alram
    case Repeat
}

protocol cood {
    var isActive: String { get }
}
enum Coordinator: cood {
    var isActive: String {
        return ""
    }
    
    case push(vc: UIViewController)
    case dismiss
    
    var coordinator: Void {
        switch self {
        case let .push(vc):
            return vc.present(ScheduleAddViewController(), animated: true, completion: nil)
        default:
            break
        }
    }
}

// ------
class AlramRelationListViewController: BottomPopupViewController {

    
    var alramState: AlramListState?
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorInset = .zero
        table.isUserInteractionEnabled = true
        return table
    }()
    
    
    // topView
    let topLittleImage: UIImageView = {
        let image = UIImageView()
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
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    //
    
    
    let alramListTextArray: [String] = ["없음", "10분 전", "30분 전", "1시간 전", "3시간 전", "12시간 전", "1일 전"]
    let repeatListTextArray: [String] = ["없음", "매일", "매주", "매월", "매년"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configuration()
        constraints()
        
        topDismissButton.addTarget(self, action: #selector(dismissActive(_:)), for: .touchUpInside)
    }
    
    @objc func dismissActive(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - TableView

extension AlramRelationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch alramState {
        
        case .Alram:
            return alramListTextArray.count
            
        case .Repeat:
            return repeatListTextArray.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch alramState {
        
        case .Alram:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmListCell.identifier, for: indexPath) as? AlarmListCell else { return UITableViewCell() }
            
            cell.textLabel?.text = alramListTextArray[indexPath.row]
            return cell
            
        case .Repeat:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmListCell.identifier, for: indexPath) as? AlarmListCell else { return UITableViewCell() }
            
            cell.textLabel?.text = repeatListTextArray[indexPath.row]
            return cell
            
        default:
            return UITableViewCell()
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
