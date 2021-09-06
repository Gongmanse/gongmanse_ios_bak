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
    private var listCount = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let lectureNibName = UINib(nibName: thumbnailCellIdentifier, bundle: nil)
        tableView.register(lectureNibName, forCellReuseIdentifier: thumbnailCellIdentifier)
        
        requestLectureList(offset: 0)
    }

    func requestLectureList(offset: Int) {
        
        let lectureApi = RequestLectureListAPI(offset: offset)
        lectureApi.requestLectureList(complition: { [weak self] result in
            if offset == 0 {
                
                self?.allLectureThumbnail = result
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }else {
                
                self?.allLectureThumbnail?.append(contentsOf: result)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
}

extension IntroduceInstructorVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = view.frame.width - 20
        return (width - 20) / 16 * 9
    }
}

extension IntroduceInstructorVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLectureThumbnail?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: thumbnailCellIdentifier, for: indexPath) as? LectureThumbnailCell else { return UITableViewCell() }
        
        
        let thumbnailList = allLectureThumbnail?[indexPath.row].fullthumbnail ?? ""
//        cell.thumbnail.setImageUrl(thumbnailList)
        cell.thumbnail.kf.setImage(with: URL(string: thumbnailList))
        cell.thumbnail.layer.cornerRadius = 13
        
        cell.selectionStyle = .none
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == totalRows - 1{
            listCount += 20
            requestLectureList(offset: listCount)
        }
        
        return cell
    }
}
