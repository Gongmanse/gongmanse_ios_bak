//
//  ProgressPopupVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit
import BottomPopup

enum selectedIndex {
    case grade
    case chapter
}

class ProgressPopupVC: BottomPopupViewController {
    
    //MARK: - Properties
    
    var selectedBtnIndex: selectedIndex?
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    var chapters: [String] = []
    var _selectedItem: String = ""
    
    let grades = ["모든 학년", "초등학교 1학년", "초등학교 2학년", "초등학교 3학년", "초등학교 4학년", "초등학교 5학년", "초등학교 6학년", "중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewlabel: UILabel!
    @IBOutlet weak var ivType: UIImageView!
    
    
    //MARK: - Lifecyce
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
        
        if selectedBtnIndex! == .grade {
            viewlabel.text = "학년"
            ivType.image = UIImage(named: "popupClass")
        } else {
            viewlabel.text = "단원"
            ivType.image = UIImage(named: "popupUnit")
        }
    }
    
    // BottomPopup
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
    //
    
    //MARK: - Helper functions
    
    func configureTableview() {
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.register(UINib(nibName: "ProgressPopupCell", bundle: nil), forCellReuseIdentifier: "ProgressPopupCell")
        
        tableView.tableFooterView = UIView()
    }
    
    
    //MARK: - Actions
    
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension ProgressPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedBtnIndex! == .grade {
            return grades.count
        } else {
            return chapters.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressPopupCell", for: indexPath) as! ProgressPopupCell
        
        viewlabel.font = .appEBFontWith(size: 14)
        
        // selectedIndex 상태에 따라 다르게 표현
        if selectedBtnIndex! == .grade {
            cell.title.text = grades[indexPath.row]
            cell.title.textColor = _selectedItem == grades[indexPath.row] ? .mainOrange : .black
            cell.ivChk.isHidden = _selectedItem != grades[indexPath.row]
        } else {
            cell.title.text = chapters[indexPath.row]
            cell.title.textColor = _selectedItem == chapters[indexPath.row] ? .mainOrange : .black
            cell.ivChk.isHidden = _selectedItem != chapters[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // selectedIndex 상태에 따라 다르게 표현
        if selectedBtnIndex! == .grade {
            
            let hashable: [AnyHashable : Any] = [
                "grade": grades[indexPath.row]
            ]
            NotificationCenter.default.post(name: .getGrade, object: nil, userInfo: hashable)
            self.dismiss(animated: true, completion: nil)
        } else {
            print(chapters[indexPath.row])
            let hashable: [AnyHashable : Any] = [
                "chapterName": chapters[indexPath.row],
                "chapterNumber": indexPath.row
            ]
            NotificationCenter.default.post(name: .getSubject, object: nil, userInfo: hashable)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
} 
