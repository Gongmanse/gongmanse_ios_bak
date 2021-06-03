//
//  VideoSettingPopupController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/29.
//

import UIKit
import BottomPopup

protocol VideoSettingPopupControllerDelegate: AnyObject {
    func presentSelectionVideoPlayRateVC()
    func updateSubtitleIsOnState(_ subtitleIsOn: Bool)
}

class VideoSettingPopupController: BottomPopupViewController {
    
    // MARK: - Properties
    
    weak var delegate: VideoSettingPopupControllerDelegate?
    var currentStateSubtitle = true
    var currentStateIsVideoPlayRate = String()
    
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
    
    let fullScreenHeight = Constant.height
    var height: CGFloat = 44 * 3
    var topCornerRadius: CGFloat = 0
    var presentDuration: Double = 0.22
    var dismissDuration: Double = 0.22
    var shouldDismissInteractivelty: Bool = true
    override var popupHeight: CGFloat { return (44 * 3) }

    
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
    
    @objc
    func handleSwitchingSubtitleIsOn(_ sender: Notification) {
        
    }
    
    @objc
    func handleChangingVideoPlayRate(_ sender: Notification) {
    }
        
    override open var shouldAutorotate: Bool {
        return false
    }

    // MARK: - Helpers

    func configureUI() {
        
        /* topView */
        view.backgroundColor = .white
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
        tableView.setDimensions(height: 44 * 2, width: view.frame.width)
        tableView.anchor(top: topView.bottomAnchor,
                         left: view.leftAnchor)
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.register(VideoPlayRateCell.self, forCellReuseIdentifier: VideoPlayRateCell.reusableIdentifier)
        tableView.register(DisplaySubtitleCell.self, forCellReuseIdentifier: DisplaySubtitleCell.reusableIdentifier)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoSettingPopupController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: DisplaySubtitleCell.reusableIdentifier,
                                     for: indexPath) as! DisplaySubtitleCell
            cell.isOn = currentStateSubtitle
            return cell
            
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: VideoPlayRateCell.reusableIdentifier,
                                     for: indexPath) as! VideoPlayRateCell
            cell.stateText = self.currentStateIsVideoPlayRate
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            if currentStateSubtitle {
                currentStateSubtitle = false
                delegate?.updateSubtitleIsOnState(currentStateSubtitle)
            } else {
                currentStateSubtitle = true
                delegate?.updateSubtitleIsOnState(currentStateSubtitle)
            }
            
            tableView.reloadData()
            
            
        } else {
            // 재생속도 BottomPopup을 호출한다.
            dismiss(animated: true) {
                // Delgation을 통해 VideoController가 "SelectionVideoPlayRateVC" 를 호출한다.
                self.delegate?.presentSelectionVideoPlayRateVC()
            }
        }
    }
}



