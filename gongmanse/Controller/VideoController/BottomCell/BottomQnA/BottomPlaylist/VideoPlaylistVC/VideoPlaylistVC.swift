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
    
}

class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    
    // Delegate
    weak var playVideoDelegate: BottomPlaylistCellDelegate?
    
    // Data
    let autoPlayDataManager = AutoplayDataManager.shared
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
        
        // 자동재생이 On인 경우 받아올 데이터
        // 국영수
        if autoPlayDataManager.isAutoplayMainSubject {
            guard let inpuData = autoPlayDataManager.videoDataInMainSubjectsTab else { return }
            viewModel.autoPlayVideoData = inpuData
            
        } else {
            // 자동재생이 Off인 경우 받아올 데이터
            guard let seriesID = self.seriesID else { return }
            VideoPlaylistDataManager()
                .getVideoPlaylistDataFromAPI(VideoPlaylistInput(seriesID: seriesID,
                                                                offset: "0"),
                                             viewController: self)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        if autoPlayDataManager.isAutoplayMainSubject {
            let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
            return autoPlayDataCount
        } else {
            let dataCount = viewModel.videoData.data.count
            return dataCount
        }
        
        
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                                       for: indexPath) as? BottomPlaylistTVCell else
        { return UITableViewCell() }
        
        /**
         true : 추천
         */
        if autoPlayDataManager.currentViewTitleView == "추천" {
            let cellData = self.viewModel.videoData.data[indexPath.row]
            cell.row = indexPath.row
            cell.cellData = cellData
            let videoDataManager = VideoDataManager.shared
            if videoDataManager.currentVideoID == viewModel.videoData.data[indexPath.row].id {
                cell.highlightView.backgroundColor = .progressBackgroundColor
            } else { cell.highlightView.backgroundColor = .clear }
            return cell
            
        }
        
        if autoPlayDataManager.currentViewTitleView == "인기" {
            print("DEBUG: 인기입니다.")
        }
        
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            print("DEBUG: 국영수입니다.")
        }
        
        if autoPlayDataManager.currentViewTitleView == "과학" {
            print("DEBUG: 과학입니다.")
        }
        
        if autoPlayDataManager.currentViewTitleView == "사회" {
            print("DEBUG: 사회입니다.")
        }
        
        if autoPlayDataManager.currentViewTitleView == "기타" {
            print("DEBUG: 기타입니다.")
        }
        
        
        /**
         true : 국영수 + 자동재생 On
         false: 국영수 + 자동재생 off
         */
        if autoPlayDataManager.isAutoplayMainSubject && autoPlayDataManager.currentViewTitleView == "국영수 강의" {
            let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
            cell.row = indexPath.row
            cell.autoPlayData = autoPlayData
            return cell
        } else {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        // "BottomPlaylistCell" 에서 사용하던 delegation 그대로 사용했습니다. 06.16
        let selectedID = viewModel.videoData.data[indexPath.row].id
        playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
    }
    
}


// MARK: - API

extension VideoPlaylistVC {
    
    func didSuccessGetPlaylistData(_ response: VideoPlaylistResponse) {
        
        let getData = response.data
        self.viewModel.videoData.data = getData
        let totalPlaylistNum = response.totalNum
        let currentIndex = "2"
        
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
        
        if currentTabMenu == "추천" {
            
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
        
        
        if currentTabMenu == "국영수 강의" && autoPlayDataManager.isAutoplayMainSubject { // 국영수 + 자동재생 On
            
            for (index, _) in autoPlayDataManager.videoDataInMainSubjectsTab!.body.enumerated() {
                
                let playVideoID = autoPlayDataManager.videoDataInMainSubjectsTab?.body[index].videoId
                
                if videoDataManager.currentVideoID == playVideoID {
                    print("DEBUG: 잇슴")
                    print("DEBUG: index is \(index)")
                    //                    DispatchQueue.main.async {
                    //                        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                    //                                                   at: .top, animated: true)
                    //                    }
                }
            }
            
            // 국영수 + 자동재생 Off -> 시리즈보기
        }
    }
    
    
    
    
}
