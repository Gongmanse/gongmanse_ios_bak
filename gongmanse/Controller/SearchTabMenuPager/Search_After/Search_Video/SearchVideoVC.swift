//  Created by 김우성 on 2021/03/11.

import UIKit
/**
  // 중간 텍스트 글자 색 변경예정
 
 */
private let cellId = "SearchVideoCell"

class SearchVideoVC: UIViewController {

    //MARK: - Properties
    
    
    var pageIndex: Int!
    

    let searchVideoVM = SearchVideoViewModel()
    
    // singleton
    lazy var searchData = SearchData.shared
    //MARK: - IBOutlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var sortButtonTitle: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchVideoVM.reloadDelegate = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        numberOfLesson.font = .appBoldFontWith(size: 14)
        sortButtonTitle.titleLabel?.font = .appBoldFontWith(size: 14)
        
        // UISwitch UI 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(allKeyword(_:)), name: .searchAllNoti, object: nil)
        
        // 필터링하고 받는 곳
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFilter(_:)), name: .searchAfterVideoNoti, object: nil)
        
        
        // 검색 후 검색되면 신호받는 곳 :
        NotificationCenter.default.addObserver(self, selector: #selector(afterSearch(_:)), name: .searchAfterSearchNoti, object: nil)
    }
    
    
    @objc func afterSearch(_ sender: Notification) {
        
        // 정렬 버튼을 다시 기본인 최신순으로 돌린 후 keyword다시 적용 후 api통신
        sortButtonTitle.setTitle("최신순 ▼", for: .normal)
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: sender.userInfo?["text"] as? String ?? nil,
                                      offset: "0",
                                      sortid: "4",
                                      limit: "20")
        
    }
    
    @objc func receiveFilter(_ sender: Notification) {
        
        let acceptInfo = sender.userInfo
        
        sortButtonTitle.setTitle(acceptInfo?["sort"] as? String, for: .normal)
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: acceptInfo?["sortID"] as? String ?? nil,
                                      limit: "20")
    }
    
    @objc func allKeyword(_ sender: Notification) {
    
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: "4",
                                      limit: "20")
        
        NotificationCenter.default.removeObserver(self, name: .searchAllNoti, object: nil)
    
    }
    
    //MARK: - Actions
    
    // 필터링 기능 : BottomPopup
    // TODO: BottomPopup 새로운 Controller로 설정할 것
    // 평점순(Default), 최신순, 이름순, 과목순 
    @IBAction func handleFilter(_ sender: Any) {
        let popupVC = SearchAfterBottomPopup()
        popupVC.selectFilterState = .videoDicionary
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchVideoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchVideoVM.responseVideoModel?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchVideoCell
        
        guard let indexData = searchVideoVM.responseVideoModel?.data[indexPath.row] else { return UICollectionViewCell() }
        
        cell.title.text = indexData.sTitle
        cell.teacher.text = indexData.sTeacher
        cell.rating.text = indexData.iRating
        cell.chemistry.text = indexData.sSubject
        cell.chemistry.backgroundColor = UIColor(hex: "#\(indexData.sSubjectColor ?? "")")
        cell.videoImage.setImageUrl("\(fileBaseURL)/\(indexData.sThumbnail ?? "")")
        
        return cell
    }
}


//MARK: - UICollectionViewFlowLayout

extension SearchVideoVC: UICollectionViewDelegateFlowLayout {
    
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

extension SearchVideoVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            
            let subString = self.searchVideoVM.responseVideoModel?.totalNum ?? "0"
            let allString = "총 \(subString)개"
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, subString, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
