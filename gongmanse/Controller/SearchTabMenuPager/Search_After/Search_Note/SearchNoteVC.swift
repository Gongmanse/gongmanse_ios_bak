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
    
    var receiveNoteUserInfo: [AnyHashable:Any]? {
        didSet{
            noteApi()
        }
    }
    //MARK: - Outlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    
    func noteApi() {
        guard let userInfo = receiveNoteUserInfo else { return }
        
        searchNoteVM.reqeustNotesApi(subject: userInfo["subject"] as? String ?? "",
                                     grade: userInfo["grade"] as? String ?? "",
                                     keyword: userInfo["text"] as? String ?? "",
                                     offset: "0",
                                     sortID: "4")
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
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchNoteCell
        cell.titleLabel.text = filteredData[indexPath.row].title
        cell.teacher.text = filteredData[indexPath.row].writer
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
