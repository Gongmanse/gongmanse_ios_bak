//
//  SearchNoteVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit
import AVKit

private let cellId = "SearchNoteCell"

protocol SearchNoteVCDelegate: AnyObject {
    func serachAfterVCPIPViewDismiss1() -> CMTime
}

class SearchNoteVC: UIViewController {

    //MARK: - Properties
    weak var pipDelegate: SearchNoteVCDelegate?
    var comeFromSearchVC: Bool?
    
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
    
    var _selectedID: String? = "4"
    
    // 상담목록이 없습니다.
    private let consultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "노트검색 내역이 없습니다."
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emptyStackView.isHidden = true
        collectionView.isHidden = false
        
        if searchNoteVM.searchNotesDataModel?.data.count == 0{
            
            emptyStackView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfLesson.font = .appBoldFontWith(size: 16)
        noteSortButton.titleLabel?.font = .appBoldFontWith(size: 13)

        
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
        
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(consultLabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
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
        _selectedID = "4"
        
        searchNoteVM.infinityBool = false
        searchNoteVM.reqeustNotesApi(subject: searchData.searchSubjectNumber,
                                     grade: searchData.searchGrade,
                                     keyword: searchData.searchText,
                                     offset: "0",
                                     sortID: "4")
    }
    
    @objc func receiveNotesFilter(_ sender: Notification) {
        
        guard let userInfo = sender.userInfo else { return }
        _selectedID = userInfo["sortID"] as? String ?? nil
        noteSortButton.setTitle(userInfo["sort"] as? String ?? "", for: .normal)
        
        searchNoteVM.infinityBool = false
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
            popupVC._selectedID = _selectedID
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
        
        
        cell.teacher.text = "\(indexData?.sTeacher ?? "") 선생님"
        cell.titleLabel.text = indexData?.sTitle
        cell.chemistry.backgroundColor = UIColor(hex: "#\(indexData?.sSubjectColor ?? "000000")")
        cell.chemistry.text = indexData?.sSubject
        cell.videoButton.addTarget(self, action: #selector(connectVideo(_:)), for: .touchUpInside)
        cell.videoButton.tag = indexPath.row
        
        if indexData?.sThumbnail != nil {
            cell.titleImage.setImageUrl("\(fileBaseURL)/\(indexData?.sThumbnail ?? "")")
        }else{
            cell.titleImage.image = UIImage(named: "extraSmallUserDefault")
        }
        return cell
    }
    
    @objc func connectVideo(_ sender: UIButton) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            //0713 - added by hp
            pipDelegate?.serachAfterVCPIPViewDismiss1()
            
            AutoplayDataManager.shared.isAutoPlay = false
            AutoplayDataManager.shared.videoDataList.removeAll()
            AutoplayDataManager.shared.videoSeriesDataList.removeAll()
            AutoplayDataManager.shared.currentIndex = -1
            
            if let comeFromSearchVC = self.comeFromSearchVC {
                let vc = VideoController()
                let videoDataManager = VideoDataManager.shared
                videoDataManager.isFirstPlayVideo = true
                vc.id = searchNoteVM.searchNotesDataModel?.data[sender.tag].videoID ?? ""
                vc.modalPresentationStyle = .fullScreen
                //0711 - added by hp
                //노트 검색에서 문제풀이 노트인가를 알수 가 없음
                //마찬가지로 국영수,과학,사회,기타,나의활동의 노트에서 문제풀이 노트인가를 알수가 없음
    //            vc.isChangedName = false
                self.present(vc, animated: true)
            } else {
                //video->lectureplaylist->video 와 같은 현상을 방지하기 위한
                let vc = self.presentingViewController as! VideoController
                vc.isFullScreenMode = false
                self.dismiss(animated: false) {
                    vc.id = self.searchNoteVM.searchNotesDataModel?.data[sender.tag].videoID ?? ""
                    vc.configureDataAndNoti(true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            //0713 - added by hp
            let currentVideoTime = pipDelegate?.serachAfterVCPIPViewDismiss1()
            
            // 노트 연결
            let vc = LessonNoteController(id: searchNoteVM.searchNotesDataModel?.data[indexPath.row].videoID ?? "",
                                          token: Constant.token)
            vc.modalPresentationStyle = .fullScreen
            //0711 - edited by hp
            //노트 전체보기 화면에 SeriesID가 필요없음
//            vc.seriesID = searchNoteVM.searchNotesDataModel?.data[indexPath.row].iSeriesId ?? ""
            //현재 비디오목록의 ID뿐이므로 그 이상일때 처리가 필요할듯함(페이징처리)
            var videoIDArr: [String] = []
            for i in 0 ..< (searchNoteVM.searchNotesDataModel?.data.count)! {
                videoIDArr.append(searchNoteVM.searchNotesDataModel?.data[i].videoID ?? "")
            }
            vc.videoIDArr = videoIDArr
            vc._type = "검색"
            vc._sort = Int(_selectedID ?? "7") ?? 7
            vc._subjectNumber = searchData.searchSubjectNumber ?? ""
            vc._grade = searchData.searchGrade ?? ""
            vc._keyword = searchData.searchText ?? ""
            vc.currentVideoTime = currentVideoTime
            
            self.navigationController?.pushViewController(vc, animated: true)
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = searchNoteVM.searchNotesDataModel?.data.count  else { return }

        if indexPath.row == cellCount - 1 {
            
            if searchNoteVM.allIntiniteScroll {
                searchNoteVM.infinityBool = true
                searchNoteVM.reqeustNotesApi(subject: searchData.searchSubjectNumber,
                                             grade: searchData.searchGrade,
                                             keyword: searchData.searchText,
                                             offset: "0",
                                             sortID: _selectedID)
                
                
            }
        }
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
        return 15
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
            let strCount = subString.withCommas()
            let allString = "총 \(strCount)개"
            
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, strCount, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
