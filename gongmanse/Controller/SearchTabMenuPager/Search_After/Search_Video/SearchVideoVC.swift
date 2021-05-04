//  Created by 김우성 on 2021/03/11.

import UIKit
/**
  // 중간 텍스트 글자 색 변경예정
 
 */
private let cellId = "SearchVideoCell"

// SearchAfterVC에서 reloadData 로직 구현을 위한 Protocol
protocol ReloadDataDelegate: class {
    func reloadFilteredData(collectionView: UICollectionView)
}

class SearchVideoVC: UIViewController {

    //MARK: - Properties
    
    weak var delegate: ReloadDataDelegate?
    
    var pageIndex: Int!
    
    // TODO: API 연동하여 가져온 데이터를 넣어야함.
    // PageController의 인스턴스 생성 타이밍과 데이터 넘기는 타이밍때문에 reloadData를 Delegate 사용.
    lazy var filteredData = [Search]() {
        didSet { delegate?.reloadFilteredData(collectionView: self.collectionView) }
    }

    let searchVideoVM = SearchVideoViewModel()
    var notificationUserInfo: [AnyHashable : Any]?
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
        
        // 강의 개수 Text 속성 설정
        configurelabel(value: 3)
        
        // UISwitch UI 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(allKeyword(_:)), name: .searchAllNoti, object: nil)
        
        // 필터링하고 받는 곳
        NotificationCenter.default.addObserver(self, selector: #selector(testAction(_:)), name: .searchAfterVideoNoti, object: nil)
    }
    
    @objc func testAction(_ sender: Notification) {
        let acceptInfo = sender.userInfo
        sortButtonTitle.setTitle(acceptInfo?["sort"] as? String, for: .normal)
        
        
        searchVideoVM.requestVideoAPI(subject: notificationUserInfo?["subject"] as? String ?? nil,
                                      grade: notificationUserInfo?["grade"] as? String ?? nil,
                                      keyword: notificationUserInfo?["text"] as? String ?? nil,
                                      offset: "0",
                                      sortid: acceptInfo?["sortID"] as? String ?? nil,
                                      limit: "20")
        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("test"), object: nil)
    }
    
    @objc func allKeyword(_ sender: Notification) {
        notificationUserInfo = sender.userInfo
        
        let objected = sender.object as? String
        
        searchVideoVM.requestVideoAPI(subject: notificationUserInfo?["subject"] as? String ?? nil,
                                      grade: notificationUserInfo?["grade"] as? String ?? nil,
                                      keyword: notificationUserInfo?["text"] as? String ?? nil,
                                      offset: "0",
                                      sortid: objected,
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
    
    //MARK: - Helper functions
    
    // UILabel 부분 속성 변경 메소드
    func configurelabel(value: Int) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        
        attributedString.append(NSAttributedString(string: "\(value)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfLesson.attributedText = attributedString
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
        // TODO: ViewModel 적용해둘 것.
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
            
            // MARK: refactor: 중간 텍스트 글자 색 변경예정
            self.numberOfLesson.text = "총 \(self.searchVideoVM.responseVideoModel?.totalNum ?? "0")개"
            self.collectionView.reloadData()
        }
    }
}
