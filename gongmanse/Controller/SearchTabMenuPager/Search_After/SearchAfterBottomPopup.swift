//
//  SearchAfterBottomPopup.swift
//  gongmanse
//
//  Created by wallter on 2021/05/03.
//

import UIKit
import BottomPopup

enum filterState {
    case videoDicionary
    case consultation
    case videoNotes

}
class SearchAfterBottomPopup: BottomPopupViewController {

    //MARK: - properties
    
    private let searchAfterCellIdentifier = "SearchAfterTableCell"
    
    private let videoDicFilter = ["이름순": 1, "과목순": 2, "평점순": 3, "최신순": 4, "관련순": 7]
    private let searchConsultation = ["최신순": 4, "조회순": 5, "답변 완료순": 6]
    private let VideoNotes = ["이름순": 1, "과목순": 2, "평점순": 3, "최신순": 4]
    var _selectedID: String?
    
    var selectFilterState: filterState?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortLabel: UILabel!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: searchAfterCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: searchAfterCellIdentifier)
        
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - TableView

extension SearchAfterBottomPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectFilterState {
        case .videoDicionary:
            return videoDicFilter.count
        case .consultation:
            return searchConsultation.count
        case .videoNotes:
            return VideoNotes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: searchAfterCellIdentifier, for: indexPath) as? SearchAfterTableCell else { return UITableViewCell() }
        
        switch selectFilterState {
        
        case .videoDicionary:
            let sortVideoDic = videoDicFilter.keys.sorted(by: >)
            cell.labelText.text = sortVideoDic[indexPath.row]
            cell.labelText.textColor = String(videoDicFilter[sortVideoDic[indexPath.row]] ?? 0) == _selectedID ? .mainOrange : .black
            cell.ivChk.isHidden = String(videoDicFilter[sortVideoDic[indexPath.row]] ?? 0) != _selectedID
        case .consultation:
            let consultation = searchConsultation.keys.sorted(by: >)
            cell.labelText.text = consultation[indexPath.row]
            cell.labelText.textColor = String(searchConsultation[consultation[indexPath.row]] ?? 0) == _selectedID ? .mainOrange : .black
            cell.ivChk.isHidden = String(searchConsultation[consultation[indexPath.row]] ?? 0) != _selectedID
        case .videoNotes:
            let sortVideoNotes = VideoNotes.keys.sorted(by: >)
            cell.labelText.text = sortVideoNotes[indexPath.row]
            cell.labelText.textColor = String(VideoNotes[sortVideoNotes[indexPath.row]] ?? 0) == _selectedID ? .mainOrange : .black
            cell.ivChk.isHidden = String(VideoNotes[sortVideoNotes[indexPath.row]] ?? 0) != _selectedID
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var postInfo: [AnyHashable : Any]?
        
        switch selectFilterState {
        case .videoDicionary:
            let sortVideoDic = videoDicFilter.keys.sorted(by: >)
            postInfo = [
                "sort": "\(sortVideoDic[indexPath.row]) ▼",
                "sortID": String(videoDicFilter[sortVideoDic[indexPath.row]] ?? 0)
            ]
            
            NotificationCenter.default.post(name: .searchAfterVideoNoti, object: nil, userInfo: postInfo)
            
        case .consultation:
            let consultation = searchConsultation.keys.sorted(by: >)
            
            postInfo = [
                "sort": "\(consultation[indexPath.row]) ▼",
                "sortID": String(searchConsultation[consultation[indexPath.row]] ?? 0)
            ]
            
            NotificationCenter.default.post(name: .searchAfterConsultationNoti, object: nil, userInfo: postInfo)
            
        case .videoNotes:
            let sortVideoNotes = VideoNotes.keys.sorted(by: >)
            
            postInfo = [
                "sort": "\(sortVideoNotes[indexPath.row]) ▼",
                "sortID": String(VideoNotes[sortVideoNotes[indexPath.row]] ?? 0)
            ]
            
            NotificationCenter.default.post(name: .searchAfterNotesNoti, object: nil, userInfo: postInfo)
            
        default:
            return
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
}
