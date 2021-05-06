//
//  SearchConsultVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

private let cellId = "SearchConsultCell"

class SearchConsultVC: UIViewController {

    //MARK: - Properties

    
    var pageIndex: Int!
    
    lazy var filteredData = [Search]()
    
    //MARK: - Outlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    let searchVideoVM = SearchVideoViewModel()
    var receiveUserInfokeyword: [AnyHashable:Any]? {
        didSet {
            consultationApi()
        }
    }
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        // 강의 개수 Text 속성 설정
        configurelabel(value: 3)
        
    }
    
    func consultationApi(){
        
        searchVideoVM.requestVideoAPI(subject: receiveUserInfokeyword?["subject"] as? String ?? nil,
                                      grade: receiveUserInfokeyword?["grade"] as? String ?? nil,
                                      keyword: receiveUserInfokeyword?["text"] as? String ?? nil,
                                      offset: "0",
                                      sortid: "4",
                                      limit: "20")
    }
    //MARK: - Actions
    
    // 필터링 기능 : BottomPopup
    // TODO: BottomPopup 새로운 Controller로 설정할 것
    // 평점순(Default), 최신순, 이름순, 과목순 
    @IBAction func handleFilter(_ sender: Any) {
        let popupVC = SearchAfterBottomPopup()
        popupVC.selectFilterState = .consultation
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)   
    }
    
    //MARK: - Helper functions
    
    // UILabel 부분 속성 변경 메소드
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

extension SearchConsultVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchConsultCell
        
        // TODO: ViewModel 적용해둘 것.
        cell.questionTitle.text = filteredData[indexPath.row].title
        cell.writer.text = filteredData[indexPath.row].writer
        return cell
    }
    
    
}


//MARK: - UICollectionViewFlowLayout

extension SearchConsultVC: UICollectionViewDelegateFlowLayout {
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
