//
//  FilteringPopUpVC.swift
//  gongmanse
//
//  Created by wallter on 2021/04/06.
//

import UIKit
import BottomPopup

class FilteringGradePopUpVC: BottomPopupViewController {
    
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    var tableView = UITableView()
    let AllgradeList = ["초등학교 1학년","초등학교 2학년","초등학교 3학년","초등학교 4학년","초등학교 5학년","초등학교 6학년","중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NonCell.self, forCellReuseIdentifier: "Cell")
        tableView.showsVerticalScrollIndicator = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override var popupHeight: CGFloat {
        return height ?? CGFloat(300)
        
    }
    
    override var popupTopCornerRadius: CGFloat {
        return topCornerRadius ?? CGFloat(10)
        
    }
    
    override var popupPresentDuration: Double {
        return presentDuration ?? 0.2
        
    }
    
    override var popupDismissDuration: Double {
        return dismissDuration ?? 0.5
    }
    
    override var popupShouldDismissInteractivelty: Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    
}

extension FilteringGradePopUpVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllgradeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NonCell else { return UITableViewCell() }
        cell.textLabel?.text = AllgradeList[indexPath.row]
        return cell
    }
}

class NonCell: UITableViewCell {
    
}
