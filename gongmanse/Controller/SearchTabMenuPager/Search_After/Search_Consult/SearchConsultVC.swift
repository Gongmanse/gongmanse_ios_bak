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
    
    //MARK: - Outlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortButton: UIButton!
    
    let searchConsultationVM = SearchConsultationViewModel()
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
        searchConsultationVM.reloadDelegate = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveConsultFilter(_:)), name: .searchAfterConsultationNoti, object: nil)
    }
    
    @objc func receiveConsultFilter(_ sender: Notification) {
        sortButton.setTitle(sender.userInfo?["sort"] as? String ?? "", for: .normal)
        searchConsultationVM.requestConsultationApi(keyword: receiveUserInfokeyword?["text"] as? String ?? "",
                                                    sortId: sender.userInfo?["sortID"] as? String ?? "")
        
    }
    
    // API 불러옴
    func consultationApi(){
        
        searchConsultationVM.requestConsultationApi(keyword: receiveUserInfokeyword?["text"] as? String ?? "",
                                                    sortId: "4")
        
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
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchConsultVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchConsultationVM.responseDataModel?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? SearchConsultCell else { return UICollectionViewCell() }
        
        // TODO: ViewModel 적용해둘 것.
        
        let indexData = searchConsultationVM.responseDataModel?.data[indexPath.row]
        
        cell.questionTitle.text = indexData?.sQuestion
        cell.writer.text = indexData?.sNickname
        cell.writtenDate.text = indexData?.dtRegister ?? ""
        // label state
        let isAnswer = searchConsultationVM.answerState(state: indexData?.iAnswer ?? "0")
        cell.labelState(isAnswer)
        
        // image
        if indexData?.sProfile != nil {
            cell.profileImage.setImageUrl("\(fileBaseURL)/\(indexData?.sProfile ?? "")")
        }else {
            cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
        }
        
        if indexData?.sFilepaths != nil {
            cell.titleImage.setImageUrl("\(fileBaseURL)/\(indexData?.sFilepaths ?? "")")
        }else {
            cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
        }
        
        
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

extension SearchConsultVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            
            let subString = self.searchConsultationVM.responseDataModel?.totalNum ?? "0"
            let allString = "총 \(subString)개"
            
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, subString, .mainOrange)
            self.collectionView.reloadData()
        }
    }

}
