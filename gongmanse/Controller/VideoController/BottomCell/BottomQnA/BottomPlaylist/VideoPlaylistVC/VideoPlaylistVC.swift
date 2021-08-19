//
//  VideoPlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import UIKit


private let emptyCellIdentifier = "EmptyTableViewCell"
private let playlistCellIdentifier = "BottomPlaylistTVCell"


class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    var isMore = false
    var isLoading = false
    var totalPlaylistNum = 0
    
    // Delegate
    weak var playVideoDelegate: BottomPlaylistCellDelegate?
    
    /// 이 프로퍼티를 통해 scroll animation을 결정한다.
    var isActiveScrollAnimation: Bool = true
    
    // Data
    let autoPlayDataManager = AutoplayDataManager.shared
    let videoDataManager = VideoDataManager.shared
        
    /*var viewModel = VideoPlaylistVCViewModel() {
        didSet {
            tableView.reloadData()
            scrollUITableViewCellToCurrentVideo()
        }
    }*/
    
    var seriesID: String?
    var hashTag: String?
    
    // UI
    private let videoCountContainerView = UIView()
    private var videoHashTagLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.appRegularFontWith(size: 11)
        lb.textColor = .mainOrange
        return lb
    }()
    
    private var videoCountTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "플레이리스트"
        lb.font = UIFont.appRegularFontWith(size: 11)
        return lb
    }()
    
    private var videoCountLabel: UILabel = {
        let lb = UILabel()
        lb.text = " "
        lb.font = UIFont.appRegularFontWith(size: 11)
        return lb
    }()
    
    private var videoCountTotalLabel: UILabel = {
        let lb = UILabel()
        lb.text = " "
        lb.font = UIFont.appRegularFontWith(size: 11)
        return lb
    }()
    
    private let tableView = UITableView()
    private var isEmpty = false
    
    // MARK: - Lifecycle
    
    init(seriesID: String, hashTag: String) {
        super.init(nibName: nil, bundle: nil)
        self.seriesID = seriesID
        self.hashTag = hashTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
//        let autoPlayDM = AutoplayDataManager.shared
//        autoPlayDM.mainSubjectListCount = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        view.backgroundColor = .white
        setupTableView()
        setupContraints()
        
        isEmpty = false
        if autoPlayDataManager.isAutoPlay {
            getAutoPlayList()
            
            scrollUITableViewCellToCurrentVideo()
        } else {
            guard let seriesID = self.seriesID else { return }
            if seriesID == "0" { //문제풀이다
                isEmpty = true
                return
            }
            
            if autoPlayDataManager.currentIndex == -1 { //우선 관련시리즈내에서 해당 동영상의 위치를 가져온다
                isLoading = true
                
                VideoPlaylistDataManager().getSeriesNowPosition(seriesID, videoDataManager.currentVideoID!, viewController: self)
            } else {
                let limit = ((autoPlayDataManager.currentIndex / 20) + 1) * 20
                networkingAPIBySeriesID(offSet: 0, limit: limit)
            }
        }
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: playlistCellIdentifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: playlistCellIdentifier)
        
        let emptyCellnibName = UINib(nibName: emptyCellIdentifier, bundle: nil)
        tableView.register(emptyCellnibName, forCellReuseIdentifier: emptyCellIdentifier)
        
        tableView.rowHeight = 81
        tableView.tableFooterView = UIView()
    }
    
    func setupContraints() {
        
        videoCountContainerView.backgroundColor = .white
        view.addSubview(videoCountContainerView)
        videoCountContainerView.anchor(top: view.topAnchor,
                                       left: view.leftAnchor,
                                       right: view.rightAnchor,
                                       height: 43)
        videoCountContainerView.layer.borderColor = UIColor.progressBackgroundColor.cgColor
        videoCountContainerView.layer.borderWidth = 0.5
        
        //해시태그 라벨
        if let keyword = self.hashTag, !keyword.isEmpty {
            videoCountContainerView.addSubview(videoHashTagLabel)
            videoHashTagLabel.centerY(inView: videoCountContainerView)
            videoHashTagLabel.anchor(left: videoCountContainerView.leftAnchor,
                                        paddingLeft: 20)
            videoHashTagLabel.text = "#\(keyword)"
            
            videoCountContainerView.addSubview(videoCountTitleLabel)
            videoCountTitleLabel.centerY(inView: videoCountContainerView)
            videoCountTitleLabel.anchor(left: videoHashTagLabel.rightAnchor,
                                        paddingLeft: 20)
        } else {
            videoCountContainerView.addSubview(videoCountTitleLabel)
            videoCountTitleLabel.centerY(inView: videoCountContainerView)
            videoCountTitleLabel.anchor(left: videoCountContainerView.leftAnchor,
                                        paddingLeft: 20)
        }
        
        videoCountContainerView.addSubview(videoCountLabel)
        videoCountLabel.centerY(inView: videoCountContainerView)
        videoCountLabel.anchor(left: videoCountTitleLabel.rightAnchor,
                               paddingLeft: 10)
        
        videoCountContainerView.addSubview(videoCountTotalLabel)
        videoCountTotalLabel.centerY(inView: videoCountContainerView)
        videoCountTotalLabel.anchor(left: videoCountLabel.rightAnchor,
                                    paddingLeft: 1)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.anchor(top: videoCountContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func networkingAPIBySeriesID(offSet: Int = 0, limit: Int = 20) {
        guard let seriesID = self.seriesID else { return }
        
        isLoading = true
        
        VideoPlaylistDataManager()
            .getVideoPlaylistDataFromAPI(VideoPlaylistInput(seriesID: seriesID,
                                                            offset: "\(offSet)", limit: "\(limit)"),
                                         viewController: self)
    }
    
    func getAutoPlayList() {
        isLoading = true
        
        var sortedId = 4 //국영수, 과학, 사회, 기타, 최근영상, 즐겨찾기, 검색
        switch autoPlayDataManager.currentSort {
        case 0:
            sortedId = 4 //최신순
        case 1:
            sortedId = 3 //평점순
        case 2:
            sortedId = 1 //이름순
        case 3:
            sortedId = 2 //과목순
        case 7:
            sortedId = 7 //관련순 (검색에서만)
        default:
            sortedId = 4
        }
        
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            //전체보기,문제풀이포함
            VideoPlaylistDataManager().getSubjectList(34, autoPlayDataManager.currentFiltering == "전체보기" ? 0 : 1, sortedId, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "과학" {
            //전체보기,문제풀이포함
            VideoPlaylistDataManager().getSubjectList(36, autoPlayDataManager.currentFiltering == "전체보기" ? 0 : 1, sortedId, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "사회" {
            //전체보기,문제풀이포함
            VideoPlaylistDataManager().getSubjectList(35, autoPlayDataManager.currentFiltering == "전체보기" ? 0 : 1, sortedId, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "기타" {
            //전체보기,문제풀이포함
            VideoPlaylistDataManager().getSubjectList(37, autoPlayDataManager.currentFiltering == "전체보기" ? 0 : 1, sortedId, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "최근영상" {
            VideoPlaylistDataManager().getRecentVideoList(Constant.token, autoPlayDataManager.currentSort, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "즐겨찾기" {
            VideoPlaylistDataManager().getBookMarkList(Constant.token, autoPlayDataManager.currentSort, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "검색" {
            VideoPlaylistDataManager().getSearchVideoList(autoPlayDataManager.currentSubjectNumber, autoPlayDataManager.currentGrade, sortedId, autoPlayDataManager.currentKeyword, autoPlayDataManager.videoDataList.count, 20, self)
        } else if autoPlayDataManager.currentViewTitleView == "진도학습" {
            var limit = 20
            if autoPlayDataManager.videoDataList.count == 0 {
                limit = ((autoPlayDataManager.currentIndex / 20) + 1) * 20
            }
            
            VideoPlaylistDataManager().getJindoDetail(autoPlayDataManager.currentJindoId, autoPlayDataManager.videoDataList.count, limit, self)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if isEmpty {
            return 1
        } else {
            if autoPlayDataManager.isAutoPlay {
                let dataCount = autoPlayDataManager.videoDataList.count
                return dataCount //0이면 empty cell 1개
            } else {
                let dataCount = autoPlayDataManager.videoSeriesDataList.count
                return dataCount
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmpty {
            guard let emptyCell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
                    as? EmptyTableViewCell else { return UITableViewCell() }
            emptyCell.selectionStyle = .none
            return emptyCell
        } else {
            guard let cell = tableView
                    .dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                         for: indexPath)
                    as? BottomPlaylistTVCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            if autoPlayDataManager.isAutoPlay {
                let autoPlayData = autoPlayDataManager.videoDataList[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataList[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                
                return cell
            } else {
                let cellData = autoPlayDataManager.videoSeriesDataList[indexPath.row]
                
                cell.row = indexPath.row
                cell.cellData = cellData
                let videoDataManager = VideoDataManager.shared
                if videoDataManager.currentVideoID == autoPlayDataManager.videoSeriesDataList[indexPath.row].id {
                    cell.highlightView.backgroundColor = .progressBackgroundColor

                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                    
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEmpty {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if isEmpty {
            return
        }
        if Constant.isGuestKey {
            presentAlert(message: "이용권이 없습니다.")
            return
        } else if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            if autoPlayDataManager.isAutoPlay {
                guard let selectedID = autoPlayDataManager.videoDataList[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
            } else {
                let selectedID = autoPlayDataManager.videoSeriesDataList[indexPath.row].id
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
            }
            //0711 - edited by hp
            videoDataManager.removeVideoLastLog()
        }
    }
}


// MARK: - API

extension VideoPlaylistVC {
    func didSuccessGetVideoPosition(_ response: SeriesVideoPosition) {
        isLoading = false
        
        if let data = response.data {
            if let num = data.num {
                autoPlayDataManager.currentIndex = Int(num)!
                self.videoCountLabel.text = "\(autoPlayDataManager.currentIndex + 1)"
                
                let limit = ((autoPlayDataManager.currentIndex / 20) + 1) * 20
                networkingAPIBySeriesID(offSet: 0, limit: limit)
            }
        }
    }
    
    func didSuccessGetPlaylistData(_ response: VideoPlaylistResponse) {
        isLoading = false
        
        let getData = response.data
        isMore = response.isMore
        totalPlaylistNum = Int(response.totalNum) ?? 0
        
        self.videoCountTotalLabel.text = "/" + "\(totalPlaylistNum)"
        
        autoPlayDataManager.videoSeriesDataList.append(contentsOf: getData)
        self.tableView.reloadData()
        
        if autoPlayDataManager.videoSeriesDataList.count == getData.count { //처음만 스크롤 진행
            self.scrollUITableViewCellToCurrentVideo()
        }
    }
    
    func didSuccessAddVideolistInAutoplaying(_ response: VideolistResponse) {
        isLoading = false
        
        var needScroll = false
        if autoPlayDataManager.currentViewTitleView == "진도학습" && autoPlayDataManager.videoDataList.count == 0 {
            needScroll = true
        }
        
//        isMore = response.isMore
        totalPlaylistNum = Int(response.totalNum) ?? 0
        
        self.videoCountTotalLabel.text = "/" + "\(totalPlaylistNum)"
        
        //VideoData -> VideoModels
        if let getData = response.data, getData.count > 0 {
            for i in 0 ..< getData.count {
                let info = getData[i]
                let model = VideoModels(seriesId: info.iSeriesId, videoId: (info.video_id ?? info.id), title: info.sTitle, tags: info.sTags, teacherName: info.sTeacher, thumbnail: info.sThumbnail, subject: info.sSubject, subjectColor: info.sSubjectColor, unit: info.sUnit, rating: info.iRating, isRecommended: nil, registrationDate: info.dtDateCreated, modifiedDate: info.dtLastModified, totalRows: nil)
                autoPlayDataManager.videoDataList.append(model)
            }
        }
        isMore = totalPlaylistNum > self.autoPlayDataManager.videoDataList.count
        self.tableView.reloadData()
        
        if needScroll {
            scrollUITableViewCellToCurrentVideo()
        }
    }
}

// MARK: - 현재 재생중인 Cell로 스크롤

extension VideoPlaylistVC {
    
    /// 재생목록의 cell들 중에서 현재 재생되고 있는 cell로 이동시켜주는 메소드
    func scrollUITableViewCellToCurrentVideo() {
        
        if autoPlayDataManager.isAutoPlay {
            autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataList)
        } else {
            defaultScrollTableView()
        }
    }
    
    func autoPlayScrollTableView(videoData: [VideoModels]) {
        
        for (index, _) in videoData.enumerated() {
            
            let playVideoID = videoData[index].videoId
            
            if videoDataManager.currentVideoID == playVideoID {

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                                               at: .top, animated: self.isActiveScrollAnimation)
                    self.videoCountLabel.text = "\(index + 1)"
                }
            }
        }
        
    }
    
    
    func defaultScrollTableView() {
        let displayedData = autoPlayDataManager.videoSeriesDataList
        
        var currentIndexPathRow = Int()
        
        for (index, data) in displayedData.enumerated() {
            if videoDataManager.currentVideoID == data.id {
                currentIndexPathRow = index
                break
            }
        }
        self.tableView.scrollToRow(at: IndexPath(row: currentIndexPathRow, section: 0),
                                   at: .top, animated: self.isActiveScrollAnimation)
        self.videoCountLabel.text = "\(currentIndexPathRow + 1)"
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        //더보기
        if autoPlayDataManager.isAutoPlay {
            if isMore && indexPath.row == autoPlayDataManager.videoDataList.count - 1 {
                print("더보기=\(autoPlayDataManager.videoDataList.count)")
                getAutoPlayList()
            }
        } else {
            if isMore && indexPath.row == autoPlayDataManager.videoSeriesDataList.count - 1 {
                networkingAPIBySeriesID(offSet: autoPlayDataManager.videoSeriesDataList.count)
            }
        }
    }
}
