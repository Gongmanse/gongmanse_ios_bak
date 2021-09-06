//
//  UseLectureVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit

class UseLectureVC: UIViewController {

    var pageIndex = 0
    
    private let lectureImageList = ["manual_0","manual_1","manual_2","manual_3","manual_4","manual_5","manual_6","manual_7"]
    private let UseLectureCellIdentifier = "UseLectureCell"
    private var tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableViewSetting()
    }

    func tableViewSetting() {
        
        let lectureNib = UINib(nibName: UseLectureCellIdentifier, bundle: nil)
        tableView.register(lectureNib, forCellReuseIdentifier: UseLectureCellIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension UseLectureVC: UITableViewDelegate {
    
}

extension UseLectureVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectureImageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UseLectureCellIdentifier, for: indexPath) as? UseLectureCell else { return UITableViewCell() }
        
        /*switch UIScreen.main.scale {
        case 2.0:
            cell.lectureImage.image = UIImage(named: "\(lectureImageList[indexPath.row])")?.resize(1000)
        case 3.0:
            cell.lectureImage.image = UIImage(named: "\(lectureImageList[indexPath.row])")?.resize(2000)
        default:
            return UITableViewCell()
        }*/
        cell.lectureImage.image = UIImage(named: "\(lectureImageList[indexPath.row])")
        
        cell.selectionStyle = .none
        return cell
    }
}
