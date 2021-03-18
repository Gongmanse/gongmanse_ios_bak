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
    
    weak var delegate: ReloadDataDelegate?
    
    lazy var filteredData = [Search]() {
        didSet { delegate?.reloadFilteredData(collectionView: self.collectionView) }
    }

    
    //MARK: - Outlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 강의 개수 Text 속성 설정
        configurelabel(value: 3)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    
    //MARK: - Actions
    
    @IBAction func handleFilter(_ sender: Any) {
        if isChooseGrade { 
            let popupVC = ProgressPopupVC()
            popupVC.selectedBtnIndex = .chapter
            
            // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
            popupVC.view.frame = self.view.bounds
            self.present(popupVC, animated: true, completion: nil)
        } else {
            // 경고창
        }
    }
    
    //MARK: - Helper functions
    
    func configurelabel(value: Int) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.appBoldFontWith(size: 15)])
        
        attributedString.append(NSAttributedString(string: "\(value)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.appRegularFontWith(size: 14)]))
        
        numberOfLesson.attributedText = attributedString
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
