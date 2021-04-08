//
//  FilteringSubjectPopUpVC.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import UIKit
import BottomPopup

class FilteringSubjectPopUpVC: BottomPopupViewController {

    
    var tableView = UITableView()
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    private var subjectList: [SubjectModel] = []
    
    private var acceptToken = ""
    private var subjectFilterNumber = ""
    private var subjectFilterText = ""
    private let SubjectListCellIdentifier = "SubjectListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        let subjectListNib = UINib(nibName: SubjectListCellIdentifier, bundle: nil)
        tableView.register(subjectListNib, forCellReuseIdentifier: SubjectListCellIdentifier)
        tableView.showsVerticalScrollIndicator = false
        
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let getSubject = getSubjectAPI()
        getSubject.performSubjectAPI { [weak self] result in
            self?.subjectList.append(SubjectModel(id: "0", sName: "모든 과목"))
            self?.subjectList.append(contentsOf: result)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
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

extension FilteringSubjectPopUpVC: UITableViewDelegate {
    
}

extension FilteringSubjectPopUpVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubjectListCellIdentifier, for: indexPath) as? SubjectListCell else  { return UITableViewCell() }
        
        cell.subjectLabel.text = subjectList[indexPath.row].sName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        subjectFilterNumber = String(indexPath.row)
        subjectFilterText = subjectList[indexPath.row].sName
        
        UserDefaults.standard.setValue(subjectFilterNumber, forKey: "subjectFilterNumber")
        UserDefaults.standard.setValue(subjectFilterText, forKey: "subjectFilterText")
        
        NotificationCenter.default.post(name: NSNotification.Name("subjectFilterText"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
