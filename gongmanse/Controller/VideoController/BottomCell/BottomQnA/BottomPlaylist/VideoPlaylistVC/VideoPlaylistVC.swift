//
//  VideoPlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import UIKit

struct VideoPlaylistVCViewModel {
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    var videoData = PlayListModels(isMore: false,
                                   totalNum: "",
                                   seriesInfo: PlayListInfo(sTitle: "",
                                                            sTeacher: "",
                                                            sSubjectColor: "",
                                                            sSubject: "",
                                                            sGrade: ""),
                                   data: [PlayListData(id: "", iSeriesId: "",
                                                       sTitle: "", dtDateCreated: "",
                                                       dtLastModified: "", sSubject: "",
                                                       sTeacher: "", sSubjectColor: "",
                                                       sThumbnail: "", sUnit: "")])
    
    
    
    var autoPlayVideoData = VideoInput(body: [VideoModels(seriesId: "", videoId: "", title: "", tags: "", teacherName: "", thumbnail: "", subject: "", subjectColor: "", unit: "", rating: "", isRecommended: "", registrationDate: "", modifiedDate: "", totalRows: "")])
    
    var totalPlaylistNum: String = ""
    
    // 무한스크롤 구현을 위한 Index
    var isMore: Bool = true
    var currentOffset: Int = 20

}

class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    
    // Delegate
    weak var playVideoDelegate: BottomPlaylistCellDelegate?
    
    // Data
    let autoPlayDataManager = AutoplayDataManager.shared
    let videoDataManager = VideoDataManager.shared
    
    
    var viewModel = VideoPlaylistVCViewModel() {
        didSet {
            tableView.reloadData()
            scrollUITableViewCellToCurrentVideo()
        }
    }
    
    var seriesID: String?
    
    // UI
    private let videoCountContainerView = UIView()
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
    
    
    // MARK: - Lifecycle
    
    init(seriesID: String) {
        super.init(nibName: nil, bundle: nil)
        self.seriesID = seriesID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        setupDataFromAPI()
        view.backgroundColor = .white
        setupTableView()
        setupContraints()
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = UINib(nibName: "BottomPlaylistTVCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BottomPlaylistTVCell")
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
        
        videoCountContainerView.addSubview(videoCountTitleLabel)
        videoCountTitleLabel.centerY(inView: videoCountContainerView)
        videoCountTitleLabel.anchor(left: videoCountContainerView.leftAnchor,
                                    paddingLeft: 20)
        
        videoCountContainerView.addSubview(videoCountLabel)
        videoCountLabel.centerY(inView: videoCountContainerView)
        videoCountLabel.anchor(left: videoCountTitleLabel.rightAnchor,
                               paddingLeft: 10)
        
        videoCountContainerView.addSubview(videoCountTotalLabel)
        videoCountTotalLabel.centerY(inView: videoCountContainerView)
        videoCountTotalLabel.anchor(left: videoCountLabel.rightAnchor,
                                    paddingLeft: 1)
        
        view.addSubview(tableView)
        tableView.anchor(top: videoCountContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func setupDataFromAPI() {
        
        // 추천 및 인기
        if autoPlayDataManager.currentViewTitleView == "추천"
            || autoPlayDataManager.currentViewTitleView == "인기" {
            networkingAPIBySeriesID()
            return
        }
        
        // 국영수
        if autoPlayDataManager.isAutoplayMainSubject {
            guard let inpuData = autoPlayDataManager.videoDataInMainSubjectsTab else { return }
            viewModel.autoPlayVideoData = inpuData
            return
            
        }
        
        // 과학
        if autoPlayDataManager.isAutoplayScience {
            guard let inpuData = autoPlayDataManager.videoDataInScienceTab else { return }
            viewModel.autoPlayVideoData = inpuData
            return
            
        }
        
        // 사회
        if autoPlayDataManager.isAutoplaySocialStudy {
            guard let inpuData = autoPlayDataManager.videoDataInSocialStudyTab else { return }
            viewModel.autoPlayVideoData = inpuData
            return
        }
        
        // 기타
        if autoPlayDataManager.isAutoplayOtherSubjects {
            guard let inpuData = autoPlayDataManager.videoDataInOtherSubjectsTab else { return }
            viewModel.autoPlayVideoData = inpuData
            return
            
        }
        
        
        // 자동재생 Off
        networkingAPIBySeriesID()
    }
    
    func networkingAPIBySeriesID(offSet: Int = 0) {
        guard let seriesID = self.seriesID else { return }
        
        if viewModel.isMore {
            VideoPlaylistDataManager()
                .getVideoPlaylistDataFromAPI(VideoPlaylistInput(seriesID: seriesID,
                                                                offset: "\(offSet)"),
                                             viewController: self)
        }
    }
    
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        /**
         case) 추천, 인기
         */
        if autoPlayDataManager.currentViewTitleView == "추천"
            || autoPlayDataManager.currentViewTitleView == "인기" {
            
            let dataCount = viewModel.videoData.data.count
            return dataCount
        }
        
        /**
         국영수 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayMainSubject {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                return dataCount
            }
        }
        
        
        /**
         과학 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "과학" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayScience {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                return dataCount
            }
        }
        
        /**
         사회 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "사회" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplaySocialStudy {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                return dataCount
            }
        }
        
        /**
         기타 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "기타" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayOtherSubjects {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                return dataCount
            }
        }
        
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                     for: indexPath)
                as? BottomPlaylistTVCell else { return UITableViewCell() }
        
        /**
         true : 추천
         */
        if autoPlayDataManager.currentViewTitleView == "추천" ||
            autoPlayDataManager.currentViewTitleView == "인기" {
            let cellData = self.viewModel.videoData.data[indexPath.row]
            cell.row = indexPath.row
            cell.cellData = cellData
            let videoDataManager = VideoDataManager.shared
            if videoDataManager.currentVideoID == viewModel.videoData.data[indexPath.row].id {
                cell.highlightView.backgroundColor = .progressBackgroundColor
            } else { cell.highlightView.backgroundColor = .clear }
            return cell
            
        }
        
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            /**
             true : 국영수 + 자동재생 On
             false: 국영수 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayMainSubject {
                
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                print("DEBUG: autoPlayData \(autoPlayData)")
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInMainSubjectsTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                } else { cell.highlightView.backgroundColor = .clear }
                
                return cell
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "과학" {
            /**
             true : 과학 + 자동재생 On
             false: 과학 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayScience {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInScienceTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                } else { cell.highlightView.backgroundColor = .clear }
                
                return cell
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "사회" {
            /**
             true : 사회 + 자동재생 On
             false: 사회 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplaySocialStudy {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInSocialStudyTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "기타" {
            /**
             true : 국영수 + 자동재생 On
             false: 국영수 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayOtherSubjects {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                let videoDataManager = VideoDataManager.shared
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInOtherSubjectsTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        let cellData = self.viewModel.videoData.data[indexPath.row]
        cell.row = indexPath.row
        cell.cellData = cellData
        let videoDataManager = VideoDataManager.shared
        if videoDataManager.currentVideoID == viewModel.videoData.data[indexPath.row].id {
            cell.highlightView.backgroundColor = .progressBackgroundColor
        } else { cell.highlightView.backgroundColor = .clear }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        // "BottomPlaylistCell" 에서 사용하던 delegation 그대로 사용했습니다. 06.16
        if autoPlayDataManager.isAutoplayMainSubject ||
            autoPlayDataManager.isAutoplayScience ||
            autoPlayDataManager.isAutoplaySocialStudy ||
            autoPlayDataManager.isAutoplayOtherSubjects
            {
            guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
            playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
            
        } else {
            let selectedID = viewModel.videoData.data[indexPath.row].id
            playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
        }
        
        
    }
    
}


// MARK: - API

extension VideoPlaylistVC {
    
    func didSuccessGetPlaylistData(_ response: VideoPlaylistResponse) {
        
        let getData = response.data
        
        // 시리즈 상세리스트 불러올 때, 데이터가 더 있는지 확인하는 불리언 값
        viewModel.isMore = response.isMore
        if viewModel.isMore {
            networkingAPIBySeriesID(offSet: viewModel.currentOffset)
            viewModel.currentOffset += 20
        }
        
        
        
        if viewModel.videoData.data.first?.sTitle == "" {
            self.viewModel.videoData.data = getData
        } else {
            self.viewModel.videoData.data.append(contentsOf: getData)
        }
        
        
        // 데이터 여러번 호출 하게 되면 아래 로직을 사용할 것 06.17
        let totalPlaylistNum = response.totalNum
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.videoCountTotalLabel.text = "/" + totalPlaylistNum
        }
    }
}

// MARK: - 현재 재생중인 Cell로 스크롤

extension VideoPlaylistVC {
    
    /// 재생목록의 cell들 중에서 현재 재생되고 있는 cell로 이동시켜주는 메소드
    func scrollUITableViewCellToCurrentVideo() {
        
        let currentTabMenu = autoPlayDataManager.currentViewTitleView
        let currentTabFiltering = autoPlayDataManager.currentFiltering
        let videoDataManager = VideoDataManager.shared
        
        if currentTabMenu == "추천" || currentTabMenu == "인기" {
            defaultScrollTableView()
        }

        if currentTabMenu == "국영수" { // 국영수 + 자동재생 On
            
            if autoPlayDataManager.isAutoplayMainSubject {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInMainSubjectsTab!.body)
            } else {
                defaultScrollTableView()
            }
        }
        
        if currentTabMenu == "과학" { // 과학 + 자동재생 On
            
            if autoPlayDataManager.isAutoplayScience {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInScienceTab!.body)
            } else {
                defaultScrollTableView()
            }
        }
        
        if currentTabMenu == "사회" { // 사회 + 자동재생 On
            
            if autoPlayDataManager.isAutoplaySocialStudy {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInSocialStudyTab!.body)
            } else {
                defaultScrollTableView()
            }
        }
        
        if currentTabMenu == "기타" { // 기타 + 자동재생 On
            
            if autoPlayDataManager.isAutoplayOtherSubjects {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInOtherSubjectsTab!.body)
            } else {
                defaultScrollTableView()
            }
        }
        

        
        
    }
    
    func autoPlayScrollTableView(videoData: [VideoModels]) {
        
        for (index, _) in videoData.enumerated() {
            
            let playVideoID = videoData[index].videoId
            
            if videoDataManager.currentVideoID == playVideoID {

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                                               at: .top, animated: true)
                }
            }
        }
    }
    
    
    func defaultScrollTableView() {
        let displayedData = viewModel.videoData.data
        var currentIndexPathRow = Int()
        
        for (index, data) in displayedData.enumerated() {
            
            if videoDataManager.currentVideoID == data.id {
                currentIndexPathRow = index
                
            }
        }
        self.tableView.scrollToRow(at: IndexPath(row: currentIndexPathRow, section: 0),
                                   at: .top, animated: true)
        self.videoCountLabel.text = "\(currentIndexPathRow)" + "/\(viewModel.videoData.totalNum)"
    }
}
