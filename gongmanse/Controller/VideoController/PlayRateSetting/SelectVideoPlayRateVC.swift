//
//  SelectVideoPlayRateVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/30.
//

import UIKit
import BottomPopup

private let cellID = "SelectVideoPlayRateCell"

class SelectVideoPlayRateVC: BottomPopupViewController {

    // MARK: - Properties
    
    var tableView = UITableView()
    var topView = UIView()
    
    private let popupImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        imageView.image = image
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "설정"
        label.font = UIFont.appBoldFontWith(size: 14)
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "largeX"), for: .normal)
        button.addTarget(self, action: #selector(handleDissmiss), for: .touchUpInside)
        return button
    }()
    
    private let bottomBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    var height: CGFloat = 44 * 6
    var topCornerRadius: CGFloat = 0
    var presentDuration: Double = 0.22
    var dismissDuration: Double = 0.22
    var shouldDismissInteractivelty: Bool = true
    override var popupHeight: CGFloat { return (44 * 6) }

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Actions
    
    @objc
    func handleDissmiss() {
        self.dismiss(animated: true)
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        
        /* topView */
        view.addSubview(topView)
        topView.backgroundColor = .white
        topView.setDimensions(height: 44, width: view.frame.width)
        topView.anchor(top: view.topAnchor,
                       left: view.leftAnchor)
        
        // - 최상단 좌측 아이콘
        topView.addSubview(popupImageView)
        popupImageView.setDimensions(height: 25, width: 25)
        popupImageView.centerY(inView: topView)
        popupImageView.anchor(left: topView.leftAnchor, paddingLeft: 20)
        
        // - 중단 "옵션" 레이블
        topView.addSubview(titleLabel)
        titleLabel.setDimensions(height: 25, width: view.frame.width * 0.77)
        titleLabel.centerY(inView: topView)
        titleLabel.anchor(left: popupImageView.rightAnchor, paddingLeft: 7.4)
        
        // - 최상단 우측 "X" 버튼
        topView.addSubview(dismissButton)
        dismissButton.setDimensions(height: 25, width: 25)
        dismissButton.centerY(inView: topView)
        dismissButton.anchor(right: topView.rightAnchor, paddingRight: 20)
        
        // - 하단 경계선 레이블
        topView.addSubview(bottomBorderLine)
        bottomBorderLine.setDimensions(height: 2.25, width: view.frame.width)
        bottomBorderLine.anchor(left: topView.leftAnchor,
                                bottom: topView.bottomAnchor)
        
        /* tableView */
        view.addSubview(tableView)
        tableView.setDimensions(height: 44 * 5, width: view.frame.width)
        tableView.anchor(top: topView.bottomAnchor,
                         left: view.leftAnchor)
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.register(SelectVideoPlayRateCell.self, forCellReuseIdentifier: cellID)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension SelectVideoPlayRateVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                 for: indexPath) as! SelectVideoPlayRateCell
        cell.textLabel?.font = UIFont.appRegularFontWith(size: 11)
        
        switch indexPath.row {
        case 0:
            cell.cellLabel.text = "1.5배"
        case 1:
            cell.cellLabel.text = "1.25배"
        case 2:
            cell.cellLabel.text = "기본"
        case 3:
            cell.cellLabel.text = "0.75배"
        case 4:
            cell.cellLabel.text = "0.5배"
        default:
            cell.cellLabel.text = "기본"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        var rate = Float()

        switch indexPath.row {
        case 0:
            rate = 1.5
        case 1:
            rate = 1.25
        case 2:
            rate = 1.0
        case 3:
            rate = 0.75
        case 4:
            rate = 0.5
        default:
            rate = 1.0
        }
        NotificationCenter.default.post(name: .changePlayVideoRate, object: nil, userInfo: ["playRate" : rate])

    }
    
}

