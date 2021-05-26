//
//  SearchNoteVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

private let cellId = "SearchNoteCell"

class SearchNoteVC: UIViewController {

    //MARK: - Properties
    
    var pageIndex: Int!
    var isChooseGrade: Bool = true
    
    
    lazy var filteredData = [Search]()

    let searchNoteVM = SearchNotesViewModel()
    
    //MARK: - Outlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noteSortButton: UIButton!
    
    
    // singleton
    lazy var searchData = SearchData.shared
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfLesson.font = .appBoldFontWith(size: 16)
        noteSortButton.titleLabel?.font = .appBoldFontWith(size: 16)

        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchNoteVM.reloadDelegate = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveNotesFilter(_:)),
                                               name: .searchAfterNotesNoti,
                                               object: nil)
        
        // 검색 후 검색되면 신호받는 곳 :
        NotificationCenter.default.addObserver(self, selector: #selector(afterSearch(_:)), name: .searchAfterSearchNoti, object: nil)
        
        
        
        getsearchNoteList()
        
    }
    
    func getsearchNoteList() {
        
        searchNoteVM.reqeustNotesApi(subject: searchData.searchSubjectNumber,
                                     grade: searchData.searchGrade,
                                     keyword: searchData.searchText,
                                     offset: "0",
                                     sortID: "4")
    }
    
    @objc func afterSearch(_ sender: Notification) {
        
        // 정렬 버튼을 다시 기본인 최신순으로 돌린 후 keyword다시 적용 후 api통신
        noteSortButton.setTitle("최신순 ▼", for: .normal)
        
        searchNoteVM.reqeustNotesApi(subject: searchData.searchSubjectNumber,
                                     grade: searchData.searchGrade,
                                     keyword: searchData.searchText,
                                     offset: "0",
                                     sortID: "4")
    }
    
    @objc func receiveNotesFilter(_ sender: Notification) {
        
        guard let userInfo = sender.userInfo else { return }
        noteSortButton.setTitle(userInfo["sort"] as? String ?? "", for: .normal)
        
        searchNoteVM.reqeustNotesApi(subject: searchData.searchSubjectNumber,
                                     grade: searchData.searchGrade,
                                     keyword: searchData.searchText,
                                     offset: "0",
                                     sortID: userInfo["sortID"] as? String ?? "")
        
    }
    
    
    @IBAction func handleFilter(_ sender: Any) {
        if isChooseGrade { 
            let popupVC = SearchAfterBottomPopup()
            popupVC.selectFilterState = .videoNotes
            
            // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
            popupVC.view.frame = self.view.bounds
            self.present(popupVC, animated: true, completion: nil)
        } else {
            // 경고창
        }
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchNoteVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchNoteVM.searchNotesDataModel?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? SearchNoteCell else { return UICollectionViewCell() }
        
        let indexData = searchNoteVM.searchNotesDataModel?.data[indexPath.row]
        
        
        cell.teacher.text = indexData?.sTeacher
        cell.titleLabel.text = indexData?.sTitle
        cell.chemistry.backgroundColor = UIColor(hex: "#\(indexData?.sSubjectColor ?? "000000")")
        cell.chemistry.text = indexData?.sSubject
        
        if indexData?.sThumbnail != nil {
            cell.titleImage.setImageUrl("\(fileBaseURL)/\(indexData?.sThumbnail ?? "")")
        }else{
            cell.titleImage.image = UIImage(named: "extraSmallUserDefault")
        }
        return cell
    }
    
    
}


//MARK: - UICollectionViewFlowLayout

extension SearchNoteVC: UICollectionViewDelegateFlowLayout {
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 80)
    }
    
}

extension SearchNoteVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            
            let subString = self.searchNoteVM.searchNotesDataModel?.totalNum ?? "0"
            let allString = "총 \(subString)개"
            
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, subString, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
