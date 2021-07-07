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
    
    var detailVideo: DetailSecondVideoResponse?
    var detailData: DetailVideoInput?
    var detailVideoData: DetailSecondVideoData?
    
    // singleton
    lazy var searchData = SearchData.shared
    
    
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
        
        getDataFromJsonVideo()
        
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
        
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(consultLabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
    }
    
    func getDataFromJsonVideo() {
        
        //guard let videoId = data?.video_id else { return }
        
        if let url = URL(string: "https://api.gongmanse.com/v/video/details?video_id=9316&token=\(Constant.token)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(DetailSecondVideoResponse.self, from: data) {
                    //print(json.data)
                    self.detailVideo = json
                    self.detailVideoData = json.data
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }.resume()
        }
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
        }
        
        guard let indexVideoData = detailVideo?.data else { return }
        
        if indexVideoData.source_url == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else if indexVideoData.source_url != nil {
            let vc = VideoController()
            let videoDataManager = VideoDataManager.shared
            videoDataManager.isFirstPlayVideo = true
            vc.id = searchNoteVM.searchNotesDataModel?.data[sender.tag].videoID ?? ""
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
        
        guard let indexVideoData = detailVideo?.data else { return }
        
        if indexVideoData.source_url == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else if indexVideoData.source_url != nil {
            // 노트 연결
            let vc = LessonNoteController(id: searchNoteVM.searchNotesDataModel?.data[indexPath.row].videoID ?? "",
                                          token: Constant.token)
            vc.modalPresentationStyle = .fullScreen
            vc.seriesID = searchNoteVM.searchNotesDataModel?.data[indexPath.row].iSeriesId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = searchNoteVM.searchNotesDataModel?.data.count  else { return }

        if indexPath.row == cellCount - 1 {
            
            if searchNoteVM.allIntiniteScroll {
                searchNoteVM.infinityBool = true
                searchNoteVM.reqeustNotesApi(subject: searchData.searchSubject,
                                             grade: searchData.searchGrade,
                                             keyword: searchData.searchText,
                                             offset: "0",
                                             sortID: "4")
                
                
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
