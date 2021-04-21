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
    
    
    // 임시 Input 데이터 추후, 데이터 패칭을 통해 가져올 것.
    let grades = ["모든학년", "초등학교 1학년", "초등학교 2학년", "초등학교 3학년", "초등학교 4학년", "초등학교 5학년", "초등학교 6학년", "중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    let chapters = ["[초3]국어교과", "[초3]국어문법", "[초3]영어문법", "[초3,4]영어표현 & 어휘", "[초 - 전학년]영어발음", "[초4]영어문법"]
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Lifecyce
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
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
        cell.title.text = grades[indexPath.row]
        
        if selectedBtnIndex! == .grade {
            cell.viewModel = ProgressPopupViewModel(data: grades[indexPath.row])
        } else {
            cell.viewModel = ProgressPopupViewModel(data: chapters[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedBtnIndex! == .grade {
            
            let hashable: [AnyHashable : Any] = [
                "grade": grades[indexPath.row]
            ]
            NotificationCenter.default.post(name: NSNotification.Name.getGrade, object: nil, userInfo: hashable)
            self.dismiss(animated: true, completion: nil)
        } else {
            print(chapters[indexPath.row])
        }
    }
    
} 
