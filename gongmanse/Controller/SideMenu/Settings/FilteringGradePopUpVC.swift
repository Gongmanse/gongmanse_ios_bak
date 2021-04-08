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
    
    private var acceptToken = ""
    private var gradeFilterText = ""
    private let AllgradeList = ["모든 학년","초등학교 1학년","초등학교 2학년","초등학교 3학년","초등학교 4학년","초등학교 5학년","초등학교 6학년","중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    private let GradeListCellIdentifier = "GradeListCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        let gradeListNibName = UINib(nibName: GradeListCellIdentifier, bundle: nil)
        tableView.register(gradeListNibName, forCellReuseIdentifier: GradeListCellIdentifier)
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
        return topCornerRadius ?? CGFloat(0)
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllgradeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GradeListCellIdentifier, for: indexPath) as? GradeListCell else { return UITableViewCell() }
        
        cell.gradeLabel.text = AllgradeList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userGrade = AllgradeList[indexPath.row]
        
        UserDefaults.standard.setValue(userGrade, forKey: "gradeFilterText")
        
        NotificationCenter.default.post(name: NSNotification.Name("gradeFilterText"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
