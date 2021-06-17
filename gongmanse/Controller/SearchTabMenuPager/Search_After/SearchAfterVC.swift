//
//  SearchAfterVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//
// TODO: filterContentForSearchText() extension으로 빼서 중복 정의 코드 정리 할 것.

import UIKit

protocol ReloadDataRecentKeywordDelegate: AnyObject {
    func reloadTableView()
}

protocol SearchAfterVCDelegate: AnyObject {
    func passTheKeywordData(keyword: String)
}


class SearchAfterVC: UIViewController {

    //MARK: - Properties
    
    // PIP 모드를 위한 프로퍼티
    var isOnPIP: Bool = false
    var pipVC: PIPController?
    var pipVideoData: PIPVideoData? {
        didSet {
            setupPIPView()
            pipVC?.pipVideoData = pipVideoData
        }
    }
    
    /// 유사 PIP 기능을 위한 ContainerView
    let pipContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let lessonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 13)
        label.textColor = .black
        return label
    }()
    
    private let teachernameLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 11)
        label.textColor = .gray
        return label
    }()
    
    private var isPlayPIPVideo: Bool = true
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(playPauseButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let xButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(xButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    
    // delegate
    weak var reloadDelegate: ReloadDataRecentKeywordDelegate?
    weak var delegate: SearchAfterVCDelegate?
    
    // 페이징 기능 구현을 위한 프로퍼티
    private var currentIndex: Int = 0
    private var pageController: UIPageViewController!
    private var filteredData: [Search]?
    var recordData = [String]()                         // 검색 기록을 넘겨주기 위한 프로퍼티
    
    // Controller Instance
    let searchVideo = SearchVideoVC()
    let searchConsult = SearchConsultVC()
    let searchNote = SearchNoteVC()
    
    // ViewModel
    let searchAfterVM = SearchVideoViewModel()
    
    // singleton
    lazy var searchData = SearchData.shared
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabsView: TabsView!

    
    //MARK: - Lifecycle

    deinit {
        dismissPIPView()
        setRemoveNotification()
        NotificationCenter.default.removeObserver(self)
        print("DEBUG: SearchAfterVC is deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.text = searchData.searchText
        
        // 서치바가 빈값이면 저장x
        if searchBar.text != "" {
            let recentVM = RecentKeywordViewModel()
            recentVM.requestSaveKeywordApi(searchBar.text ?? "")
        }
        
        configureConstraint()
        configureNavi()
        setupTabs()
        setupPageViewController()
        
        // SearchBar
        configureSearchBar()
        
        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(allKeyword(_:)), name: .searchAllNoti, object: nil)
        searchVideo.pipDelegate = self

    }
    
    @objc func allKeyword(_ sender: Notification) {
        
        searchBar.text = searchData.searchText
        
    }
    
    //MARK: - Actions
    
    @objc func dismissVC() {
        
        // PIP 모드가 실행중이였다면, 종료시킨다.
        dismissPIPView()
        setRemoveNotification()
        self.reloadDelegate?.reloadTableView()
        self.dismiss(animated: true)
    }
    
    @objc func playPauseButtonDidTap() {
        isPlayPIPVideo = !isPlayPIPVideo
        
        if isPlayPIPVideo {
            pipVC?.player?.pause()
            playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            pipVC?.player?.play()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func xButtonDidTap() {
        
        pipVC?.player?.pause()
        pipVC?.player = nil
        
        UIView.animate(withDuration: 0.22, animations: {
            self.pipContainerView.alpha = 0
        }, completion: nil)
    }
    
    // 가장 최근에 재생하던 Video로 돌아갑니다.
    // 그러므로 새로운 VC 인스턴스를 생성하지 않고 dismiss + videoLogic으로 처리합니다. 21.06.09 김우성
    @objc func pipContainerViewDidTap(_ sender: UITapGestureRecognizer) {
        
        setRemoveNotification()
        dismissSearchAfterVCOnPlayingPIP()
        // PIP에 이전영상에 대한 기록이 있으므로 화면을 새로 생성하지 않고 이전영상으로 돌아간다.
        // 재생된 시간은 전달해줘서 PIP AVPlayer가 진행된 부분부터 진행한다.
        // Delegation을 사용하지 말고, VideoController
        // 이전 영상의 Player를 조작해야하므로 Delegation을 사용한다.
        // Delegation Method를 통해 "player.seek()" 를 호출한다.
        // 이 때 seek 메소드의 파라미터로 "pipDataManager.currentPlayTime"을 입력한다.
    }

    //MARK: - Helper functions
    
    func configureSearchBar() {
        searchBar.delegate = self     
        
        // SearchBar의 상하 선이 자동으로 생겨서 제거해주기 위한 코드
        let searchBarImage = UIImage()
        searchBar.backgroundImage = searchBarImage
        searchBar.setImage(UIImage(named: "search"), for: .search, state: .normal)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        // 필터링된 데이터를 변수에 넣는 과정.
        // searchs : dummyData
        filteredData = searchs.filter({ (search: Search) -> Bool in
            return search.title.lowercased().contains(searchText.lowercased()) || search.writer.lowercased().contains(searchText.lowercased())
        })
    }
    
    func configureConstraint() {
        
        // addSubview
        view.addSubview(tabsView)
        
        // tabsView Contraint
        tabsView.anchor(top: searchBar.bottomAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        paddingTop: 5,
                        height: 55)

    }
    
    func configureNavi() {
        let title = UILabel()
        title.text = "검색"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        
        // navigationItem Back button
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    func setupTabs() {
        //탭 추가
        tabsView.tabs = [
            Tab(title: "동영상 백과"),
            Tab(title: "전문가 상담"),
            Tab(title: "노트 검색")
        ]
        
        
        //TabMode를 화면 전체 너비로 확장 된 탭의 경우 '.fixed'로 설정하고 모든 탭을 보려면 스크롤하려면 '.scrollable'로 설정
        tabsView.tabMode = .fixed
        
        //TabView 커스텀
        tabsView.titleColor = .black
        tabsView.indicatorColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        tabsView.titleFont = UIFont.boldSystemFont(ofSize: 18)
        tabsView.collectionView.backgroundColor = .white
        
        //TabsView Delegate 설정
        tabsView.delegate = self
        
        //앱이 시작될 때 선택될 탭 설정
        tabsView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
    }
    
    func setupPageViewController() {
        
        // 검색화면에서 상세 영상 실행될 때, PIP를 dismiss하기 위한 Delegation
        
        self.pageController = TabsPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        
        //pageViewController Delegate 와 Datasource 설정
        pageController.delegate = self
        pageController.dataSource = self
        
        //앱이 시작될 때 PageViewController 에서 선택한 ViewController를 설정
        pageController.setViewControllers([showViewController(0)!], direction: .forward, animated: true, completion: nil)
        
        //pageViewController 제약조건 추가
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.pageController.view.topAnchor.constraint(equalTo: self.tabsView.bottomAnchor),
            self.pageController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pageController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pageController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.pageController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabsView.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func showViewController(_ index: Int) -> UIViewController? {
        if (self.tabsView.tabs.count == 0) || (index >= self.tabsView.tabs.count) {
            return nil
        }
        
        
        currentIndex = index
        
        // PageController가 나타날 때마다 실행되는 코드
        if index == 0 {

            searchVideo.pageIndex = index
            return searchVideo
        } else if index == 1 {
            
            searchConsult.pageIndex = index
            return searchConsult
        } else if index == 2 {
            
            searchNote.pageIndex = index
            return searchNote
        } else {
            let contentVC = SearchVideoVC()
            contentVC.pageIndex = index
            return contentVC
        }
        
    }
    
    func setupPIPView() {
        
        let pipHeight = view.frame.height * 0.085
        view.addSubview(pipContainerView)
        pipContainerView.anchor(left: view.leftAnchor,
                                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                height: pipHeight)
        
        pipVC = PIPController()
        guard let pipVC = self.pipVC else { return }
        
        let pipContainerViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(pipContainerViewDidTap))
        pipContainerView.addGestureRecognizer(pipContainerViewTapGesture)
        pipContainerView.isUserInteractionEnabled = true
        pipContainerView.layer.borderColor = UIColor.gray.cgColor
        pipContainerView.layer.borderWidth = CGFloat(0.5)
        pipContainerView.addSubview(pipVC.view)
        pipVC.view.anchor(top:pipContainerView.topAnchor)
        pipVC.view.centerY(inView: pipContainerView)
        pipVC.view.setDimensions(height: pipHeight,
                                 width: pipHeight * 1.77)
        
        pipContainerView.addSubview(xButton)
        xButton.setDimensions(height: 25, width: 25)
        xButton.centerY(inView: pipContainerView)
        xButton.anchor(right: pipContainerView.rightAnchor,
                       paddingRight: 5)
        
        pipContainerView.addSubview(playPauseButton)
        playPauseButton.setDimensions(height: 25,
                                      width: 25)
        playPauseButton.centerY(inView: pipContainerView)
        playPauseButton.anchor(right: xButton.leftAnchor,
                       paddingRight: 20)
        
        pipContainerView.addSubview(lessonTitleLabel)
        lessonTitleLabel.anchor(top: pipContainerView.topAnchor,
                                left: pipContainerView.leftAnchor,
                                paddingTop: 13,
                                paddingLeft: pipHeight * 1.77 + 5,
                                height: 17)
        lessonTitleLabel.text = pipVideoData?.videoTitle ?? ""
        
        pipContainerView.addSubview(teachernameLabel)
        teachernameLabel.anchor(top: lessonTitleLabel.bottomAnchor,
                                left: lessonTitleLabel.leftAnchor,
                                paddingTop: 5,
                                height: 15)
        teachernameLabel.text = pipVideoData?.teacherName ?? ""
        
        
    }
    
    func dismissPIPView() {
        // PIP 모드가 실행중이였다면, 종료시킨다.
        pipVC?.player?.pause()
        pipVC?.player = nil
        pipVC?.removePeriodicTimeObserver()
        pipVC?.removeFromParent()
        pipVC = nil
    }
    
    /// PIP 영상이 실행되고 있는데, 이전 영상화면으로 돌아가고 싶은 경우 호출하는 메소드
    func dismissSearchAfterVCOnPlayingPIP() {
        // 1 PIP 영상을 제거한다.

        // 2 PIP-Player에서 현재까지 재생된 시간을 SingleTon 에 입력한다.
        let pipDataManager = PIPDataManager.shared
        guard let pipVC = self.pipVC else { return }
            
        pipVC.player?.pause()
        setRemoveNotification()
        // 3 싱글톤 객체 프로퍼티에 현재 재생된 시간을 CMTime으로 입력한다.
        pipDataManager.currentVideoCMTime = pipVC.currentVideoTime
        dismiss(animated: false)
    }
        
    func setRemoveNotification() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

//MARK: - TabsDelegate

extension SearchAfterVC: TabsDelegate {
    
    func tabsViewDidSelectItemAt(position: Int) {
        // 탭이 이동된 다음에 실행되므로 여기서 데이터 전송
//        searchConsult.filteredData = self.filteredData
//        searchNote.filteredData = self.filteredData
        
        //선택한 탭 셀 위치가 pageController의 현재 위치와 동일한 지 확인하고 그렇지 않은 경우 앞으로 또는 뒤로 이동
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
            tabsView.collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}


//MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension SearchAfterVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    //앞으로 갈 때 viewController 반환
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = getVCPageIndex(vc)
        //뷰 페이저가 탭 수만큼 되면 아무 작업 하지 않기
        if index == tabsView.tabs.count {
            return nil
        } else {
            index += 1
            return self.showViewController(index)
        }
    }
    
    //뒤로 갈 때 viewController 반환
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = getVCPageIndex(vc)
        if index == 0 {
            return nil
        } else {
            index -= 1
            return self.showViewController(index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            if completed {
                guard let vc = pageViewController.viewControllers?.first else { return }
                
                let index: Int
                
                index = getVCPageIndex(vc)
                
                tabsView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
                
                //scrollable을 사용하여 스크롤 할 때 TabsView의 탭을 중앙에 표시
                tabsView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    //UIPageViewController 에있는 UIViewController에 저장된 현재 위치를 반환
    func getVCPageIndex(_ viewController: UIViewController?) -> Int {
        switch viewController {
        case is SearchVideoVC:
            let vc = viewController as! SearchVideoVC
            return vc.pageIndex
        case is SearchConsultVC:
            let vc = viewController as! SearchConsultVC
            return vc.pageIndex
        case is SearchNoteVC:
            let vc = viewController as! SearchNoteVC
            return vc.pageIndex
        default:
            let vc = viewController as! SearchVideoVC
            return vc.pageIndex        
            
        }
        
    }
}


//MARK: - UISearchBarDelegate

extension SearchAfterVC: UISearchBarDelegate {
    
    // SearchBar를 클릭하여 타이핑할 때, 호출되는 메소드
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 추후 사용 예정
    }
    
    // SearchBar의 타이핑이 끝났을 때, 호출되는 메소드
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // 추후 사용 예정
    }
    
    // 취소버튼 클릭 시, 키보드 닫기 및 검색어 초기화하는 메소드
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    // 키보드에서 검색버튼을 눌렀을 때
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 데이터 필터링
        filterContentForSearchText(searchBar.text!)
        
        
        // 기존 userinfoKeyword의 text에 텍스트를 수정 변경
        searchData.searchText = searchBar.text
        
        NotificationCenter.default.post(name: .searchAfterSearchNoti, object: nil, userInfo: nil)
        
        
        // SearchVC로 검색어 데이터 전달 로직
        let vc = SearchVC(nibName: "SearchVC", bundle: nil)
        vc.keywordLog.append(searchBar.text!)
        
        // SearchAfterVC dismiss 시, 데이터 전달하기 위한 array에 검색 내역 추가
        self.recordData.append(searchBar.text!)
        self.delegate?.passTheKeywordData(keyword: searchBar.text!)
        
        // SearchBar 실행 시, 나타났던 키보드 및 Placeholder 초기화
        // 삭제버튼(검색어 입력할 때, 우측에 있는 x마크) 제거
        self.searchBar.showsCancelButton = false
        
        self.searchBar.resignFirstResponder()
        
    }
}


extension SearchAfterVC: RecentKeywordVCDelegate {
    func reloadTableView(tv: UITableView) {
        tv.reloadData()
    }
    
    
}

extension SearchAfterVC: SearchVideoVCDelegate {
    func serachAfterVCPIPViewDismiss() {
        pipVC?.player?.pause()
    }
}
