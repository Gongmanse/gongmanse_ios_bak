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
    case sort
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
    // 임시 Input 데이터 추후, 데이터 패칭을 통해 가져올 것.
    let grades = ["모든 학년", "초등학교 1학년", "초등학교 2학년", "초등학교 3학년", "초등학교 4학년", "초등학교 5학년", "초등학교 6학년", "중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    
    let sortIdentifier = ["이름순": 1, "과목순": 2, "평점순": 3, "최신순": 4, "관련순": 7]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewlabel: UILabel!
    
    
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
        } else if selectedBtnIndex! == .chapter{
            return chapters.count
        } else {
            return sortIdentifier.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressPopupCell", for: indexPath) as! ProgressPopupCell
//        cell.title.text = grades[indexPath.row]
        
        viewlabel.font = .appEBFontWith(size: 14)
        if selectedBtnIndex! == .grade {
            cell.title.text = grades[indexPath.row]
            viewlabel.text = "학년"
        } else if selectedBtnIndex! == .chapter{
            cell.title.text = chapters[indexPath.row]
            viewlabel.text = "과목"
        } else {
            
            var t = Array(self.sortIdentifier.keys).sorted()
            cell.title.text = "\(t[indexPath.row])"
            viewlabel.text = "정렬"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedBtnIndex! == .grade {
            
            let hashable: [AnyHashable : Any] = [
                "grade": grades[indexPath.row]
            ]
            NotificationCenter.default.post(name: .getGrade, object: nil, userInfo: hashable)
            self.dismiss(animated: true, completion: nil)
        } else if selectedBtnIndex! == .chapter{
            print(chapters[indexPath.row])
        } else {
            print(Array(self.sortIdentifier.values)[indexPath.row])
        }
    }
    
} 
