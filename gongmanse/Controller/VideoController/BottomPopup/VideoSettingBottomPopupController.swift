//
//  VideoSettingBottomPopupController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/29.
//

import UIKit
import BottomPopup

class VideoSettingBottomPopupController: BottomPopupViewController {
    
    // MARK: - Property
    
    private let tableView = UITableView()
    
    
    // MARK: BottomPopup Property
    
    var height: CGFloat?
    
    var topCornerRadius: CGFloat?
    
    var presentDuration: Double?
    
    var dismissDuration: Double?
    
    var shouldDismissInteractivelty: Bool?
    
    override var popupHeight: CGFloat {
        return height ?? CGFloat(view.frame.height * 0.45)
    }
    
    override var popupTopCornerRadius: CGFloat { return topCornerRadius ?? CGFloat(0) }
    
    override var popupPresentDuration: Double { return presentDuration ?? 0.22 }
    
    override var popupDismissDuration: Double { return dismissDuration ?? 0.22 }
    
    override var popupShouldDismissInteractivelty: Bool { return shouldDismissInteractivelty ?? true }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(IsDisplaySubtitleTableViewCell.self,
                           forCellReuseIdentifier: IsDisplaySubtitleTableViewCell.reusableIdentifier)
        
        
        tableView.setDimensions(height: view.frame.height, width: view.frame.width)
        tableView.anchor(top: view.topAnchor,
                         left: view.leftAnchor)
        view.backgroundColor = .white
    }
    
    
    // MARK: - Actions
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoSettingBottomPopupController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: IsDisplaySubtitleTableViewCell.reusableIdentifier,
                                                     for: indexPath) as! IsDisplaySubtitleTableViewCell
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: IsDisplaySubtitleTableViewCell.reusableIdentifier,
                                                     for: indexPath) as! IsDisplaySubtitleTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: IsDisplaySubtitleTableViewCell.reusableIdentifier,
                                                     for: indexPath) as! IsDisplaySubtitleTableViewCell
            return cell
        }
        
    }
}


// MARK: - IsDisplaySubtitleTableViewCellDelegate

extension VideoSettingBottomPopupController: IsDisplaySubtitleTableViewCellDelegate {
    
    func dismissBottomPopup() {
        
        self.dismiss(animated: true)
    }
}
