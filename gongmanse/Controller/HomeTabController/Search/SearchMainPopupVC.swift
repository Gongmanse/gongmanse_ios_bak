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
    

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var ivType: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    private let searchCellIdentifier = "SearchMainCell"
    
    var gradeList: [String] = ["모든 학년", "초등", "중등", "고등"]
    
    
    var mainList: SearchMainButtonState?
    var subjectModel: [SubjectModel] = []
    
    //싱글턴
    let searchData = SearchData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbTitle.text = mainList == .grade ? "학년" : "과목"
        ivType.image = mainList == .grade ? UIImage(named: "popupClass") : UIImage(named: "popupSubject")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: searchCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: searchCellIdentifier)
        
        let subjectApi = getSubjectAPI()
        subjectApi.performSubjectAPI { [weak self] result in
            self?.subjectModel.append(SubjectModel(id: "0", sName: "모든 과목"))
            self?.subjectModel.append(contentsOf: result)
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
            var grade = searchData.searchGrade
            if grade == nil {
                grade = "모든 학년"
            }
            cell.titleLabel.text = gradeList[indexPath.row]
            cell.titleLabel.textColor = grade == gradeList[indexPath.row] ? .mainOrange : .black
            cell.ivChk.isHidden = grade != gradeList[indexPath.row]
        } else {
            var subjectNum = searchData.searchSubjectNumber
            if subjectNum == nil {
                subjectNum = "0"
            }
            cell.titleLabel.text = subjectModel[indexPath.row].sName
            cell.titleLabel.textColor = subjectNum == subjectModel[indexPath.row].id ? .mainOrange : .black
            cell.ivChk.isHidden = subjectNum != subjectModel[indexPath.row].id
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mainList! == .grade {
            
            searchData.searchGrade = gradeList[indexPath.row]
            if gradeList[indexPath.row] == "모든 학년" {
                searchData.searchGrade = nil
            }
            
            let selectGrade = gradeList[indexPath.row]
            NotificationCenter.default.post(name: .searchGradeNoti, object: selectGrade)
            
        }else {
            let selectSubjectName = subjectModel[indexPath.row].sName
            let selectSubjectID = subjectModel[indexPath.row].id
            
            let selectHashable = [
                "name": selectSubjectName,
                "Id": selectSubjectID
            ]
            
            searchData.searchSubject = selectSubjectName
            searchData.searchSubjectNumber = selectSubjectID
            
            if searchData.searchSubjectNumber == "0" {
                searchData.searchSubjectNumber = nil
            }
            
            NotificationCenter.default.post(name: .searchSubjectNoti, object: nil, userInfo: selectHashable)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
extension SearchMainPopupVC: TableReloadData {
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
