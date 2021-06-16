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
    
    var totalPlaylistNum: String = ""
    
}

class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    
    // Delegate
    weak var playVideoDelegate: BottomPlaylistCellDelegate?
    
    // Data
    var viewModel = VideoPlaylistVCViewModel() {
        didSet { tableView.reloadData() }
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
        lb.text = "22/36"
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
        
        view.addSubview(tableView)
        tableView.anchor(top: videoCountContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func setupDataFromAPI() {
        guard let seriesID = self.seriesID else { return }
        VideoPlaylistDataManager()
            .getVideoPlaylistDataFromAPI(VideoPlaylistInput(seriesID: seriesID,
                                                            offset: "0"),
                                         viewController: self)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        let dataCount = viewModel.videoData.data.count
        return dataCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                                       for: indexPath) as? BottomPlaylistTVCell else
        { return UITableViewCell() }
        cell.viewModel = self.viewModel
        cell.row = indexPath.row
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
            self.videoCountLabel.text = currentIndex + "/" + totalPlaylistNum
        }
    }
}

