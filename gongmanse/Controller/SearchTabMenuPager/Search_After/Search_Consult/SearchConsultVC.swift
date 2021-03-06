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
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    let searchConsultationVM = SearchConsultationViewModel()

    
    // singleton
    lazy var searchData = SearchData.shared
    
    var _selectedID: String? = "4"
    
    // 상담목록이 없습니다.
    private let consultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "상담 내역이 없습니다."
        return label
    }()
    
    private let emptyAlert: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "alert")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    //MARK: - Lifecycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emptyStackView.isHidden = true
        collectionView.isHidden = false
        
        if searchConsultationVM.responseDataModel?.data.count == 0{
            
            emptyStackView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        numberOfLesson.font = .appBoldFontWith(size: 16)
        sortButton.titleLabel?.font = .appBoldFontWith(size: 13)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchConsultationVM.reloadDelegate = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveConsultFilter(_:)), name: .searchAfterConsultationNoti, object: nil)
        
        // 검색 후 검색되면 신호받는 곳 :
        NotificationCenter.default.addObserver(self, selector: #selector(afterSearch(_:)), name: .searchAfterSearchNoti, object: nil)
        
        
        getSearchConsultation()
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(consultLabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    
    func getSearchConsultation() {
        
        searchConsultationVM.requestConsultationApi(keyword: searchData.searchText,
                                                    sortId: "4", offset: "\(self.searchConsultationVM.responseDataModel?.data.count ?? 0)")
    }
    
    @objc func afterSearch(_ sender: Notification) {
        
        // 정렬 버튼을 다시 기본인 최신순으로 돌린 후 keyword다시 적용 후 api통신
        sortButton.setTitle("최신순 ▼", for: .normal)
        
        searchConsultationVM.responseDataModel?.data.removeAll()
        searchConsultationVM.requestConsultationApi(keyword: searchData.searchText,
                                                    sortId: "4", offset: "\(self.searchConsultationVM.responseDataModel?.data.count ?? 0)")
    }
    
    @objc func receiveConsultFilter(_ sender: Notification) {
        let acceptInfo = sender.userInfo
        _selectedID = acceptInfo?["sortID"] as? String ?? nil
        
        sortButton.setTitle(sender.userInfo?["sort"] as? String ?? "", for: .normal)
        
        searchConsultationVM.responseDataModel?.data.removeAll()
        searchConsultationVM.requestConsultationApi(keyword: searchData.searchText,
                                                    sortId: sender.userInfo?["sortID"] as? String ?? "",
                                                    offset: "\(self.searchConsultationVM.responseDataModel?.data.count ?? 0)")
        
    }
    
    //MARK: - Actions
    
    // 필터링 기능 : BottomPopup
    // TODO: BottomPopup 새로운 Controller로 설정할 것
    // 평점순(Default), 최신순, 이름순, 과목순 
    @IBAction func handleFilter(_ sender: Any) {
        let popupVC = SearchAfterBottomPopup()
        popupVC.selectFilterState = .consultation
        popupVC._selectedID = _selectedID
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
        
        cell.questionTitle.text = indexData?.sQuestion?.htmlEscaped.trimmingCharacters(in: .whitespacesAndNewlines)// 문장 시작과 끝의 공백&줄바꿈 제거
        cell.writer.text = indexData?.sNickname
        
        cell.writtenDate.text = indexData?.simpleDt ?? ""
        
        // label state
        let isAnswer = searchConsultationVM.answerState(state: indexData?.iAnswer ?? "0")
        cell.labelState(isAnswer)
        
        // image
        if indexData?.sProfile != nil {
            cell.profileImage.setImageUrl("\(fileBaseURL)/\(indexData?.sProfile ?? "")")
        }else {
            cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
        }
        
//        if indexData?.sFilepaths != nil {
//            cell.titleImage.setImageUrl("\(fileBaseURL)/\(indexData?.sFilepaths ?? "")")
//        }else {
//            cell.titleImage.image = UIImage(named: "extraSmallUserDefault")
//        }
        if indexData?.sFilepaths == nil {
            cell.titleImage.contentMode = .scaleAspectFit
            cell.titleImage.image = UIImage(named: "app_icon")
        } else {
            cell.titleImage.contentMode = .scaleAspectFill
            cell.titleImage.sd_setImage(with: URL(string: "\(fileBaseURL)/\(indexData?.sFilepaths ?? "")")) { img, err, type, URL in
                if img == nil {
                    cell.titleImage.contentMode = .scaleAspectFit
                    cell.titleImage.image = UIImage(named: "app_icon")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ExpertConsultationDetailVC") as? ExpertConsultationDetailVC else { return }
        
        let data = searchConsultationVM.responseDataModel?.data[indexPath.row]
        
        
        let input = ExpertModelData(cu_id: data?.consultationID,
                                    iAuthor: data?.iAuthor,
                                    iViews: data?.iViews,
                                    consultation_id: data?.consultationID,
                                    dtAnswerRegister: data?.dtAnswerRegister,
                                    sQuestion: data?.sQuestion,
                                    sNickname: data?.sNickname,
                                    sProfile: data?.sProfile,
                                    sAnswer: data?.sAnswer,
                                    iAnswer: data?.iAnswer,
                                    dtRegister: data?.dtRegister,
                                    sFilepaths: data?.sFilepaths)
        vc.receiveData = input
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == (self.searchConsultationVM.responseDataModel?.data.count ?? 0) - 1 && !searchConsultationVM.isLoading {
            searchConsultationVM.requestConsultationApi(keyword: searchData.searchText,
                                                        sortId: _selectedID,
                                                        offset: "\(self.searchConsultationVM.responseDataModel?.data.count ?? 0)")
        }
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
            let strCount = subString.withCommas()
            let allString = "총 \(strCount)개"
            
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, strCount, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
