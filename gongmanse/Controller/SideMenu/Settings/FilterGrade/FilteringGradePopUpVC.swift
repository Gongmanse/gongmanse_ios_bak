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
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
    
    private var acceptToken = ""
    private var gradeFilterText = ""
    private let AllgradeList = ["모든 학년","초등학교 1학년","초등학교 2학년","초등학교 3학년","초등학교 4학년","초등학교 5학년","초등학교 6학년","중학교 1학년","중학교 2학년","중학교 3학년","고등학교 1학년","고등학교 2학년","고등학교 3학년"]
    private let GradeListCellIdentifier = "GradeListCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset.left = 0
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
    
    @objc func headerCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        
        let gradeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        gradeImage.image = UIImage(named: "popupClass")
        gradeImage.sizeToFit()
        gradeImage.contentMode = .scaleAspectFit
        gradeImage.setContentHuggingPriority(.required, for: .horizontal)
        
        let gradeLabelText = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 10))
        gradeLabelText.text = "학년"
        gradeLabelText.textAlignment = .left
        gradeLabelText.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        gradeLabelText.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setImage(UIImage(named: "smallX"), for: .normal)
        cancelButton.addTarget(self, action: #selector(headerCancelButton(_:)), for: .touchUpInside)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        
        let contourLine = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 2))
        contourLine.backgroundColor = UIColor.rgb(red: 237, green: 118, blue: 0)
        
        header.backgroundColor = .white
        header.addSubview(contourLine)
        header.addSubview(stackView)
        stackView.addArrangedSubview(gradeImage)
        stackView.addArrangedSubview(gradeLabelText)
        stackView.addArrangedSubview(cancelButton)
        
        contourLine.translatesAutoresizingMaskIntoConstraints = false
        contourLine.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        contourLine.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        contourLine.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        contourLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: header.topAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contourLine.bottomAnchor, constant: -8).isActive = true
        
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
        
        let grade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String ?? "모든 학년"
        cell.gradeLabel.text = AllgradeList[indexPath.row]
        cell.gradeLabel.textColor = grade == AllgradeList[indexPath.row] ? .mainOrange : .black
        cell.ivChk.isHidden = grade != AllgradeList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userGrade = AllgradeList[indexPath.row]
        UserDefaults.standard.removeObject(forKey: "gradeFilterText")
        UserDefaults.standard.setValue(userGrade, forKey: "gradeFilterText")
        
        NotificationCenter.default.post(name: NSNotification.Name("gradeFilterText"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
