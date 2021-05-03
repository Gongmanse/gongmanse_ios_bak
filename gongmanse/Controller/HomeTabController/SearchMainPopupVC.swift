//
//  SearchMainPopupVC.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//

import UIKit
import BottomPopup

enum SearchMainButtonState {
    case grade, subject
}


class SearchMainPopupVC: BottomPopupViewController {
    

    @IBOutlet weak var tableView: UITableView!
    private let searchCellIdentifier = "SearchMainCell"
    
    var gradeList: [String] = ["모든 학년", "초등", "중등", "고등"]
    let sortIdentifier = ["이름순": 1, "과목순": 2, "평점순": 3, "최신순": 4, "관련순": 7]
    
    
    var mainList: SearchMainButtonState?
    var subjectModel: [SubjectModel] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: searchCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: searchCellIdentifier)
        
        let subjectApi = getSubjectAPI()
        subjectApi.performSubjectAPI { [weak self] result in
            self?.subjectModel = result
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchMainPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mainList! == .grade {
            return gradeList.count
        } else {
            return subjectModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: searchCellIdentifier, for: indexPath) as? SearchMainCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        
        if mainList! == .grade {
            cell.titleLabel.text = gradeList[indexPath.row]
        } else {
            cell.titleLabel.text = subjectModel[indexPath.row].sName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mainList! == .grade {
            let selectGrade = gradeList[indexPath.row]
            NotificationCenter.default.post(name: .searchGradeNoti, object: selectGrade)
            
        }else {
            let selectSubjectName = subjectModel[indexPath.row].sName
            let selectSubjectID = subjectModel[indexPath.row].id
            
            let selectHashable = [
                "name": selectSubjectName,
                "Id": selectSubjectID
            ]
            NotificationCenter.default.post(name: .searchSubjectNoti, object: nil, userInfo: selectHashable)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
extension SearchMainPopupVC: PopularReloadData {
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
