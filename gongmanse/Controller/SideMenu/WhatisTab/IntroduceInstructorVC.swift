//
//  IntroduceInstructorVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit

class IntroduceInstructorVC: UIViewController {

    var pageIndex = 0
    private var allLectureThumbnail: [LectureThumbnail]?
    private let thumbnailCellIdentifier = "LectureThumbnailCell"
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        let lectureNibName = UINib(nibName: thumbnailCellIdentifier, bundle: nil)
        tableView.register(lectureNibName, forCellReuseIdentifier: thumbnailCellIdentifier)
        
        let lectureApi = RequestLectureListAPI(offset: 0)
        lectureApi.requestLectureList(complition: { [weak self] result in
            self?.allLectureThumbnail = result
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }

}

extension IntroduceInstructorVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension IntroduceInstructorVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLectureThumbnail?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: thumbnailCellIdentifier, for: indexPath) as? LectureThumbnailCell else { return UITableViewCell() }
        
        
        let thumbnailList = allLectureThumbnail?[indexPath.row].fullthumbnail ?? ""
        cell.thumbnail.setImageUrl(thumbnailList)
        cell.selectionStyle = .none
        
        return cell
    }
}
