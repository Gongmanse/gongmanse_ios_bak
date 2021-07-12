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

private let emptyCellIdentifier = "EmptyTableViewCell"
private let playlistCellIdentifier = "BottomPlaylistTVCell"


class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    
    // Delegate
    weak var playVideoDelegate: BottomPlaylistCellDelegate?
    
    /// 이 프로퍼티를 통해 scroll animation을 결정한다.
    var isActiveScrollAnimation: Bool = true
    
    // Data
    let autoPlayDataManager = AutoplayDataManager.shared
    let videoDataManager = VideoDataManager.shared
    
    var detailVideo: DetailSecondVideoResponse?
    var detailData: DetailVideoInput?
    var detailVideoData: DetailSecondVideoData?
    
    var viewModel = VideoPlaylistVCViewModel() {
        didSet {
            tableView.reloadData()
            scrollUITableViewCellToCurrentVideo()
        }
    }
    
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
        getDataFromJsonVideo()
        let autoPlayDM = AutoplayDataManager.shared
        autoPlayDM.mainSubjectListCount = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
                    self.tableView.reloadData()
                }
                
            }.resume()
        }
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
        
        let nibName = UINib(nibName: playlistCellIdentifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: playlistCellIdentifier)
        
        let emptyCellnibName = UINib(nibName: emptyCellIdentifier, bundle: nil)
        tableView.register(emptyCellnibName, forCellReuseIdentifier: emptyCellIdentifier)
        
        tableView.rowHeight = 81
        if self.viewModel.videoData.data.count == 1 {
//            self.videoCountContainerView.alpha = 0
//            tableView.rowHeight = view.frame.height * 0.5
//            tableView.separatorStyle = .none
        } else {
            
            
        }
        
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
        tableView.anchor(top: videoCountContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    /// 재생목록을 가져오기 위한 메소드
    func setupDataFromAPI() {
        
        // 추천 및 인기
        if autoPlayDataManager.currentViewTitleView == "추천"
            || autoPlayDataManager.currentViewTitleView == "인기" {
            networkingAPIBySeriesID()
            return
        }
        
        // 국영수
        let isAutoplayOnMainSubject = autoPlayDataManager.isAutoplayMainSubject
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInMainSubjectsTab,
                                              isAutoPlay: isAutoplayOnMainSubject,
                                              comeFromTab: "국영수")
        
        let isAutoplayOnMainProblem = autoPlayDataManager.isAutoPlayMainProblemTab
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInProblemTab,
                                              isAutoPlay: isAutoplayOnMainProblem,
                                              comeFromTab: "국영수")
        
        // 과학
        let isAutoplayOnScience = autoPlayDataManager.isAutoplayScience
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInScienceTab,
                                              isAutoPlay: isAutoplayOnScience,
                                              comeFromTab: "과학")
        
        // 사회
        let isAutoplayOnSocial = autoPlayDataManager.isAutoplaySocialStudy
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInSocialStudyTab,
                                              isAutoPlay: isAutoplayOnSocial,
                                              comeFromTab: "사회")

        // 기타
        let isAutoplayOnOther = autoPlayDataManager.isAutoplayOtherSubjects
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInOtherSubjectsTab,
                                              isAutoPlay: isAutoplayOnOther,
                                              comeFromTab: "기타")
        
        // 검색
        let isAutoplayOnSearch = autoPlayDataManager.isAutoplaySearchTab
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInSearchTab,
                                              isAutoPlay: isAutoplayOnSearch,
                                              comeFromTab: "검색")
        
        
        // TODO: 나의활동 - 최근영상
        let isAutoplayOnRecent = autoPlayDataManager.isAutoplayRecentTab
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInRecentVideoMyActTab,
                                              isAutoPlay: isAutoplayOnRecent,
                                              comeFromTab: "최근영상")
        
        // TODO: 나의활동 - 즐겨찾기
        let isAutoplayOnBookmark = autoPlayDataManager.isAutoplayBookMarkTab
        insertVideoDataToViewModelAutoPlaying(autoPlayDataManager.videoDataInBookMarkVideoMyActTab,
                                              isAutoPlay: isAutoplayOnBookmark,
                                              comeFromTab: "즐겨찾기")
        
        
        // 자동재생 Off - DEFAULT Setting
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
    
    
    func insertVideoDataToViewModelAutoPlaying(_ inputData: VideoInput?,
                                               isAutoPlay: Bool,
                                               comeFromTab: String) {
        
        if autoPlayDataManager.currentViewTitleView == comeFromTab {
            if isAutoPlay {
                guard let inpuData = inputData else { return }
                viewModel.autoPlayVideoData = inpuData
                return
            }
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
            self.videoCountTotalLabel.text = "/" + "\(dataCount)"
            return dataCount
        }
        
        /**
         국영수 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayMainSubject {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"

                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
                return dataCount
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "국영수" && autoPlayDataManager.currentFiltering == "문제 풀이" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayMainSubject {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"

                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
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
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
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
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
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
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
                return dataCount
            }
        }
        
        /**
         검색 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "검색" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplaySearchTab {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
                return dataCount
            }
        }
        
        // TODO: 나의활동 - 최근영상
        /**
         최근영상 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "최근영상" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayRecentTab {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
                return dataCount
            }
        }
        
        // TODO: 나의활동 - 즐겨찾기
        /**
         검색 자동재생 On/Off
         */
        if autoPlayDataManager.currentViewTitleView == "즐겨찾기" {
            // 자동재생 On
            if autoPlayDataManager.isAutoplayBookMarkTab {
                let autoPlayDataCount = viewModel.autoPlayVideoData.body.count
                self.videoCountTotalLabel.text = "/" + "\(autoPlayDataCount)"
                return autoPlayDataCount
                
                // 자동재생 Off
            } else {
                let dataCount = viewModel.videoData.data.count
                self.videoCountTotalLabel.text = "/" + "\(dataCount)"
                return dataCount
            }
        }
        
        
        let dataCount = viewModel.videoData.data.count
        self.videoCountTotalLabel.text = "/" + "\(dataCount)"
        return dataCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel.videoData.data.count == 1 {
            guard let emptyCell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
                    as? EmptyTableViewCell else { return UITableViewCell() }
            emptyCell.selectionStyle = .none
            tableView.isScrollEnabled = false
            return emptyCell
        } else {
            tableView.isScrollEnabled = true
        }
        
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                     for: indexPath)
                as? BottomPlaylistTVCell else { return UITableViewCell() }
        cell.selectionStyle = .none
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

                self.videoCountLabel.text = "\(indexPath.row + 1)"
                
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
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInMainSubjectsTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                
                return cell
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "국영수" && autoPlayDataManager.currentFiltering == "문제 풀이" {
            /**
             true : 국영수 + 자동재생 On
             false: 국영수 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayMainSubject {
                
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInProblemTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
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
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
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
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
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
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        if autoPlayDataManager.currentViewTitleView == "검색" {
            /**
             true : 검색 + 자동재생 On
             false: 검색 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplaySearchTab {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                let videoDataManager = VideoDataManager.shared
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInSearchTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        
        // TODO: 나의활동 - 최근영상
        if autoPlayDataManager.currentViewTitleView == "최근영상" {
            /**
             true : 검색 + 자동재생 On
             false: 검색 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayRecentTab {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                let videoDataManager = VideoDataManager.shared
                
                guard let currentVideoID
                        = autoPlayDataManager.videoDataInRecentVideoMyActTab?.body[indexPath.row].videoId
                else { return cell }
                
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        // TODO: 나의활동 - 즐겨찾기
        if autoPlayDataManager.currentViewTitleView == "즐겨찾기" {
            /**
             true : 검색 + 자동재생 On
             false: 검색 + 자동재생 off
             */
            if autoPlayDataManager.isAutoplayBookMarkTab {
                let autoPlayData = self.viewModel.autoPlayVideoData.body[indexPath.row]
                cell.row = indexPath.row
                cell.autoPlayData = autoPlayData
                let videoDataManager = VideoDataManager.shared

                guard let currentVideoID
                        = autoPlayDataManager.videoDataInBookMarkVideoMyActTab?.body[indexPath.row].videoId
                else { return cell }
                
                print("DEBUG: 즐겨찾기버그 is \(videoDataManager.currentVideoID)")
                print("DEBUG: 즐겨찾기버그 is \(currentVideoID)")
                if videoDataManager.currentVideoID == currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                    self.videoCountLabel.text = "\(indexPath.row + 1)"
                } else { cell.highlightView.backgroundColor = .clear }
                return cell
            }
        }
        
        
        // DEFAULT - 시리즈보기
        // 시리즈를 보여주는 CellForRowAt 로직
        let cellData = self.viewModel.videoData.data[indexPath.row]
        cell.row = indexPath.row
        cell.cellData = cellData
        let videoDataManager = VideoDataManager.shared
        if videoDataManager.currentVideoID == viewModel.videoData.data[indexPath.row].id {
            self.videoCountLabel.text = "\(indexPath.row + 1)"
            cell.highlightView.backgroundColor = .progressBackgroundColor
        } else { cell.highlightView.backgroundColor = .clear }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.viewModel.videoData.data.count == 1 {
            return tableView.frame.height
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        if Constant.isGuestKey {
            presentAlert(message: "이용권이 없습니다.")
            return
        } else if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
        
        guard let indexVideoData = detailVideo?.data else { return }
        
        if indexVideoData.source_url == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else if indexVideoData.source_url != nil {
            tableViewCellDidTap(indexPath: indexPath, "국영수")
            tableViewCellDidTap(indexPath: indexPath, "과학")
            tableViewCellDidTap(indexPath: indexPath, "사회")
            tableViewCellDidTap(indexPath: indexPath, "기타")
            tableViewCellDidTap(indexPath: indexPath, "검색")
            tableViewCellDidTap(indexPath: indexPath, "최근영상")
            tableViewCellDidTap(indexPath: indexPath, "즐겨찾기")
            tableViewCellDidTap(indexPath: indexPath, "문제 풀이")
            
            // TODO: 나의활동 - 최근영상
            // TODO: 나의활동 - 즐겨찾기
            
            if autoPlayDataManager.currentViewTitleView == "추천" ||
                autoPlayDataManager.currentViewTitleView == "인기" {
                // 추천 및 인기
                let selectedID = viewModel.videoData.data[indexPath.row].id
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                
                //0711 - edited by hp
                videoDataManager.removeVideoLastLog()
                
                
                videoDataManager.addVideoIDLog(videoID: selectedID)
            }
        }
    }
    
    func tableViewCellDidTap(indexPath: IndexPath, _ tabname: String) {
        let comeFromTabname = autoPlayDataManager.currentViewTitleView
        
        if comeFromTabname == tabname {
            // 국영수
            if autoPlayDataManager.isAutoplayMainSubject {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            //국영수 문제풀이
            if autoPlayDataManager.isAutoPlayMainProblemTab {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
            }
            
            // 과학
            if autoPlayDataManager.isAutoplayScience {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            // 사회
            if autoPlayDataManager.isAutoplaySocialStudy {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            // 기타
            if autoPlayDataManager.isAutoplayOtherSubjects {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            // 검색
            if autoPlayDataManager.isAutoplaySearchTab {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            // TODO: 나의활동 - 최근영상
            if autoPlayDataManager.isAutoplayRecentTab {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
                
            }
            
            // TODO: 나의활동 - 즐겨찾기
            if autoPlayDataManager.isAutoplayBookMarkTab {
                guard let selectedID = viewModel.autoPlayVideoData.body[indexPath.row].videoId else { return }
                playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
                videoDataManager.addVideoIDLog(videoID: selectedID)
                return
            }
            
            
            // DEFAULT
            
            let selectedID = viewModel.videoData.data[indexPath.row].id
            playVideoDelegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: selectedID)
            videoDataManager.addVideoIDLog(videoID: selectedID)
            return
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
//            self.videoCountTotalLabel.text = "/" + totalPlaylistNum
//            self.videoCountTotalLabel.text = totalPlaylistNum
        }
    }
    
    func didSuccessAddVideolistInAutoplaying(_ response: VideoInput) {
     
        if autoPlayDataManager.currentViewTitleView == "국영수" {
            
            if autoPlayDataManager.isAutoplayMainSubject {
                autoPlayDataManager.videoDataInMainSubjectsTab?.body.append(contentsOf: response.body)
                viewModel.autoPlayVideoData.body.append(contentsOf: response.body)
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let startCellRow = self.viewModel.autoPlayVideoData.body.count - 20
                    self.tableView.scrollToRow(at: IndexPath(row: startCellRow, section: 0),
                                          at: .top, animated: self.isActiveScrollAnimation)
//                    self.videoCountTotalLabel.text = "/" + "\(self.viewModel.autoPlayVideoData.body.count)"
//                    self.defaultScrollTableView()
                }
            }
        } else if autoPlayDataManager.currentViewTitleView == "과학" {
            
            if autoPlayDataManager.isAutoplayScience {
                autoPlayDataManager.videoDataInScienceTab?.body.append(contentsOf: response.body)
                viewModel.autoPlayVideoData.body.append(contentsOf: response.body)
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let startCellRow = self.viewModel.autoPlayVideoData.body.count - 20
                    self.tableView.scrollToRow(at: IndexPath(row: startCellRow, section: 0),
                                          at: .top, animated: false)
//                    self.videoCountTotalLabel.text = "/" + "\(self.viewModel.autoPlayVideoData.body.count)"
//                    self.defaultScrollTableView()
                }
            }
            
        } else if autoPlayDataManager.currentViewTitleView == "사회" {
            
            if autoPlayDataManager.isAutoplaySocialStudy {
                autoPlayDataManager.videoDataInSocialStudyTab?.body.append(contentsOf: response.body)
                viewModel.autoPlayVideoData.body.append(contentsOf: response.body)
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let startCellRow = self.viewModel.autoPlayVideoData.body.count - 20
                    self.tableView.scrollToRow(at: IndexPath(row: startCellRow, section: 0),
                                               at: .top, animated: self.isActiveScrollAnimation)
//                    self.videoCountTotalLabel.text = "/" + "\(self.viewModel.autoPlayVideoData.body.count)"
//                    self.defaultScrollTableView()
                }
            }
        } else if autoPlayDataManager.currentViewTitleView == "기타" {
            
            if autoPlayDataManager.isAutoplayOtherSubjects {
                autoPlayDataManager.videoDataInOtherSubjectsTab?.body.append(contentsOf: response.body)
                viewModel.autoPlayVideoData.body.append(contentsOf: response.body)
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let startCellRow = self.viewModel.autoPlayVideoData.body.count - 20
                    self.tableView.scrollToRow(at: IndexPath(row: startCellRow, section: 0),
                                          at: .top, animated: self.isActiveScrollAnimation)
//                    self.videoCountTotalLabel.text = "/" + "\(self.viewModel.autoPlayVideoData.body.count)"
//                    self.defaultScrollTableView()
                }
            }
        }
        
        
        

        
        
        
    }
    
    func addVideoDataScrolledBottom(_ comeFromeTab: String,_ isAutoPlay: Bool, appendData: [VideoModels]) {
        
        var tabDataArr: VideoInput?
        
        if comeFromeTab == "국영수" {
            tabDataArr = autoPlayDataManager.videoDataInMainSubjectsTab
        } else if comeFromeTab == "과학" {
            tabDataArr = autoPlayDataManager.videoDataInScienceTab
        } else if comeFromeTab == "사회" {
            tabDataArr = autoPlayDataManager.videoDataInSocialStudyTab
        } else if comeFromeTab == "기타" {
            tabDataArr = autoPlayDataManager.videoDataInOtherSubjectsTab
        }
        
        if autoPlayDataManager.currentViewTitleView == comeFromeTab {

            if isAutoPlay {
                tabDataArr?.body.append(contentsOf: appendData)
                viewModel.autoPlayVideoData.body.append(contentsOf: appendData)
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let startCellRow = self.viewModel.autoPlayVideoData.body.count - 20
                    self.tableView.scrollToRow(at: IndexPath(row: startCellRow, section: 0),
                                          at: .top, animated: self.isActiveScrollAnimation)
                }
            }
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
            return
        }

        if currentTabMenu == "국영수" { // 국영수 + 자동재생 On
            
            if autoPlayDataManager.isAutoplayMainSubject {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInMainSubjectsTab!.body)
            } else {
                defaultScrollTableView()
            }
            return
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
            return
        }
        
        if currentTabMenu == "기타" { // 기타 + 자동재생 On
            
            if autoPlayDataManager.isAutoplayOtherSubjects {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInOtherSubjectsTab!.body)
            } else {
                defaultScrollTableView()
            }
            return
        }
        
        if currentTabMenu == "최근영상" {
            if autoPlayDataManager.isAutoplayRecentTab {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInRecentVideoMyActTab!.body)
            } else {
                defaultScrollTableView()
            }
            return
        }
        
        if currentTabMenu == "즐겨찾기" {
            if autoPlayDataManager.isAutoplayBookMarkTab {
                autoPlayScrollTableView(videoData: autoPlayDataManager.videoDataInBookMarkVideoMyActTab!.body)
            } else {
                defaultScrollTableView()
            }
            return
        }
        
        defaultScrollTableView()
    }
    
    func autoPlayScrollTableView(videoData: [VideoModels]) {
        
        for (index, _) in videoData.enumerated() {
            
            let playVideoID = videoData[index].videoId
            
            if videoDataManager.currentVideoID == playVideoID {

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0),
                                               at: .top, animated: self.isActiveScrollAnimation)
                    self.videoCountLabel.text = "\(index)"

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
                break
            }
        }
        self.tableView.scrollToRow(at: IndexPath(row: currentIndexPathRow, section: 0),
                                   at: .top, animated: self.isActiveScrollAnimation)
        self.videoCountLabel.text = "\(currentIndexPathRow)"
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("DEBUG: 현재 인덱스는 \(indexPath.row)")
        var cellCount = 0

        if autoPlayDataManager.currentViewTitleView == "국영수" {
            guard let cellCountKor = autoPlayDataManager.videoDataInMainSubjectsTab?.body.count else { return }
            cellCount = cellCountKor

        } else if autoPlayDataManager.currentViewTitleView == "과학" {
            guard let cellCountSci = autoPlayDataManager.videoDataInScienceTab?.body.count else { return }
            cellCount = cellCountSci

        } else if autoPlayDataManager.currentViewTitleView == "사회" {
            guard let cellCountSoc = autoPlayDataManager.videoDataInSocialStudyTab?.body.count else { return }
            cellCount = cellCountSoc

        } else if autoPlayDataManager.currentViewTitleView == "기타" {
            guard let cellCountOth = autoPlayDataManager.videoDataInOtherSubjectsTab?.body.count else { return }
            cellCount = cellCountOth

        }
        
        
        print("DEBUG: 셀카운트는 \(cellCount)")

        
        if indexPath.row > cellCount - 5 {
            
            print("DEBUG: 마지막에 도달했음.")
//            listCount += 20
//            getDataFromJson()

            /**
             경우의 수
             1. 하나만 켜진 경우 -> isAuto 로 확인하면된다.
             2. 두 개 켜진 경우 -> 내가 들어온 탭 + isAuto를 확인하면 된다.
             3. 세 개 켜진 경우 -> "
             */
            didScrollTableViewAction(comeFromTab: "국영수", autoPlayDataManager.isAutoplayMainSubject)
            didScrollTableViewAction(comeFromTab: "과학", autoPlayDataManager.isAutoplayScience)
            didScrollTableViewAction(comeFromTab: "사회", autoPlayDataManager.isAutoplaySocialStudy)
            didScrollTableViewAction(comeFromTab: "기타", autoPlayDataManager.isAutoplayOtherSubjects)
            
            let tabname = autoPlayDataManager.currentViewTitleView
            
            if tabname == "추천" || tabname == "인기" {
//                presentAlertInPlaylist(message: "마지막 영상입니다.")
            }

            
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset
//        let bounds = scrollView.bounds
//        let size = scrollView.contentSize
//        let inset = scrollView.contentInset
//        let y = offset.y + bounds.size.height - inset.bottom
//        let h = size.height
//        let reload_distance:CGFloat = 30.0
//        if y > (h + reload_distance) {
//
//            /**
//             경우의 수
//             1. 하나만 켜진 경우 -> isAuto 로 확인하면된다.
//             2. 두 개 켜진 경우 -> 내가 들어온 탭 + isAuto를 확인하면 된다.
//             3. 세 개 켜진 경우 -> "
//             */
//            didScrollTableViewAction(comeFromTab: "국영수", autoPlayDataManager.isAutoplayMainSubject)
//            didScrollTableViewAction(comeFromTab: "과학", autoPlayDataManager.isAutoplayScience)
//            didScrollTableViewAction(comeFromTab: "사회", autoPlayDataManager.isAutoplaySocialStudy)
//            didScrollTableViewAction(comeFromTab: "기타", autoPlayDataManager.isAutoplayOtherSubjects)
//
//            let tabname = autoPlayDataManager.currentViewTitleView
//
//            if tabname == "추천" || tabname == "인기" {
//                presentAlertInPlaylist(message: "마지막 영상입니다.")
//            }
//        }
    }
    
    func didScrollTableViewAction(comeFromTab: String, _ isAutoPlay: Bool =  false) {
        if autoPlayDataManager.currentViewTitleView == comeFromTab {
            if isAutoPlay {
                // 탭에 있는 데이터를 API로 부터 가져온다.
                var url = String()
                if comeFromTab == "국영수" {
                    url = KoreanEnglishMath_Video_URL
                } else if  comeFromTab == "과학" {
                    url = Science_Video_URL
                } else if  comeFromTab == "사회" {
                    url = SocialStudies_Video_URL
                } else if  comeFromTab == "기타" {
                    url = OtherSubjects_Video_URL
                }

                VideoPlaylistDataManager().addVideolistInAutoplaying(baseURL: url, self)
                
            } else {
                // 시리즈보기를 재생목록에 보여준 상태이다.
//                presentAlertInPlaylist(message: "마지막 영상입니다.")
            }
        }
    }
    
    func presentAlertInPlaylist(message: String) {
        
        let alertSuperView = UIView()
        alertSuperView.backgroundColor
            = UIColor.black.withAlphaComponent(0.05)
        alertSuperView.layer.cornerRadius = 17
        alertSuperView.isHidden = true
        
        let alertLabel = UILabel()
        alertLabel.font = UIFont.appBoldFontWith(size: 12)
        alertLabel.textColor = .white
        
        self.view.addSubview(alertSuperView)
        alertSuperView.centerX(inView: self.view)
        alertSuperView.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 50,
                              width: self.view.frame.width * 0.89,
                              height: 37)
        
        alertSuperView.addSubview(alertLabel)
        alertLabel.centerY(inView: alertSuperView)
        alertLabel.centerX(inView: alertSuperView)
        alertLabel.setDimensions(height: 37,
                                 width: self.view.frame.width * 0.83)
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        
        alertLabel.text = message
        alertSuperView.alpha = 1.0
        alertSuperView.isHidden = false
        UIView.animate(withDuration: 2.0,
                       delay: 1.0,
                       options: .curveEaseIn,
                       animations: { alertSuperView.alpha = 0 },
                       completion: { _ in
                        alertSuperView.removeFromSuperview()
                       })
    }
}
