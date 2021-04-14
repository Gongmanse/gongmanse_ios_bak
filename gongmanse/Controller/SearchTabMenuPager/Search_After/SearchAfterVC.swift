//
//  SearchAfterVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//
// TODO: filterContentForSearchText() extension으로 빼서 중복 정의 코드 정리 할 것.

import UIKit

protocol ReloadDataRecentKeywordDelegate: class {
    func reloadTableView()
}

protocol SearchAfterVCDelegate: class {
    func passTheKeywordData(keyword: String)
}


class SearchAfterVC: UIViewController {

    //MARK: - Properties

    // delegate
    weak var reloadDelegate: ReloadDataRecentKeywordDelegate?
    weak var delegate: SearchAfterVCDelegate?
    
    // 페이징 기능 구현을 위한 프로퍼티
    private var currentIndex: Int = 0
    private var pageController: UIPageViewController!
    private var filteredData: [Search]
    var recordData = [String]()                         // 검색 기록을 넘겨주기 위한 프로퍼티
    
    // Controller Instance
    let searchVideo = SearchVideoVC()
    let searchConsult = SearchConsultVC()
    let searchNote = SearchNoteVC()

    //MARK: - IBOutlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabsView: TabsView!
    
    //MARK: - Lifecycle
    
    // 검색 결과를 넘겨받기 위한 초기화 메소드
    init(data: [Search]) {
        self.filteredData = data
        super.init(nibName: "SearchAfterVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraint()
        configureNavi()
        setupTabs()
        setupPageViewController()
        
        // SearchBar
        configureSearchBar()
        
        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    
    
    //MARK: - Actions
    
    @objc func dismissVC() {
        // TODO: delegate 메소드를 호출하여 "RecentKeywordVC"를 Reload 한다.
        self.reloadDelegate?.reloadTableView()
        self.dismiss(animated: true)
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
            searchVideo.filteredData = filteredData   // 최초 데이터 전달 + 페이지 전환될 때마다 전달
            searchVideo.pageIndex = index
            return searchVideo
        } else if index == 1 {
            searchConsult.delegate = self
            searchConsult.pageIndex = index
            return searchConsult
        } else if index == 2 {
            searchNote.delegate = self
            searchNote.pageIndex = index
            return searchNote
        } else {
            let contentVC = SearchVideoVC()
            contentVC.filteredData = filteredData
            contentVC.pageIndex = index
            return contentVC
        }
        
    }
    
    
}

//MARK: - TabsDelegate

extension SearchAfterVC: TabsDelegate {
    func tabsViewDidSelectItemAt(position: Int) {
        // 탭이 이동된 다음에 실행되므로 여기서 데이터 전송
        searchConsult.filteredData = self.filteredData
        searchNote.filteredData = self.filteredData
        
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
        
        // SearchVC로 검색어 데이터 전달 로직
        let vc = SearchVC(nibName: "SearchVC", bundle: nil)
        vc.keywordLog.append(searchBar.text!)
        
        // SearchAfterVC dismiss 시, 데이터 전달하기 위한 array에 검색 내역 추가
        self.recordData.append(searchBar.text!)
        self.delegate?.passTheKeywordData(keyword: searchBar.text!)
        
        // SearchBar 실행 시, 나타났던 키보드 및 Placeholder 초기화
        // 삭제버튼(검색어 입력할 때, 우측에 있는 x마크) 제거
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        // 화면이동하는 Controller로 데이터 전달 
        searchVideo.delegate = self
        searchVideo.filteredData = self.filteredData    // 검색 결과 화면에서 데이터를 전달
        
        
        
        
        
    }
}


// SearchVideoVC의 collectionView 데이터 업데이트를 위한 Protocol
extension SearchAfterVC: ReloadDataDelegate {
    func reloadFilteredData(collectionView: UICollectionView) {
        collectionView.reloadData()
    }
}

extension SearchAfterVC: RecentKeywordVCDelegate {
    func reloadTableView(tv: UITableView) {
        tv.reloadData()
    }
    
    
}