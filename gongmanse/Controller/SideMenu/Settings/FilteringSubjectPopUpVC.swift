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
        tableView.separatorInset.left = 0
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
    
    @objc func headerCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilteringSubjectPopUpVC: UITableViewDelegate {
    
}

extension FilteringSubjectPopUpVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        let gradeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        gradeImage.image = UIImage(named: "popupClass")
        gradeImage.sizeToFit()
        gradeImage.contentMode = .scaleAspectFit
        
        let gradeLabelText = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 10))
        gradeLabelText.text = "과목"
        gradeLabelText.textAlignment = .left
        gradeLabelText.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setImage(UIImage(named: "smallX"), for: .normal)
        cancelButton.addTarget(self, action: #selector(headerCancelButton(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        
        let contourLine = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 2))
        contourLine.backgroundColor = UIColor.rgb(red: 237, green: 118, blue: 0)
        
        headerview.backgroundColor = .white
        headerview.addSubview(contourLine)
        headerview.addSubview(stackView)
        stackView.addArrangedSubview(gradeImage)
        stackView.addArrangedSubview(gradeLabelText)
        stackView.addArrangedSubview(cancelButton)
        
        contourLine.translatesAutoresizingMaskIntoConstraints = false
        contourLine.leadingAnchor.constraint(equalTo: headerview.leadingAnchor).isActive = true
        contourLine.trailingAnchor.constraint(equalTo: headerview.trailingAnchor).isActive = true
        contourLine.bottomAnchor.constraint(equalTo: headerview.bottomAnchor).isActive = true
        contourLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contourLine.bottomAnchor, constant: -8).isActive = true
        
        return headerview
    }
    
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
