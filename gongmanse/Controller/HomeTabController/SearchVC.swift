
/* *
 ? = Optional
 검색어?, 학년?, 과목? 전달할 메소드 작성
 검색어 isEmpty or nil 이면 에러처리할 alert 구현
 
 최근 검색어 전달할 메소드 분리
 
 */


protocol ReloadDataInRecentKeywordVCDelegate: class {
    func finalReload()
}

import UIKit

class SearchVC: UIViewController {

    //MARK: - Properties
    
    weak var delegate: ReloadDataInRecentKeywordVCDelegate?
    
    // 페이징 기능 구현을 위한 프로퍼티
    private var currentIndex: Int = 0
    private var pageController: UIPageViewController!
   
    // UISearchBar를 통한 filtering 이후 데이터 저장할 변수
    var filteredData = [Search]()                   // 검색한 후, 검색 "결과"에 대한 데이터
    var keywordLog = [String]()                     // 검색한 키워드 "기록"에 대한 데이터
    
    var removedDuplicatedData: [String] {           // 중복 삭제한 데이터
        return removeDuplicate(keywordLog)
    }
    
    
    // 학년을 선택하지 않고 단원을 클릭 시, 경고창을 띄우기 위한 Index
    private var isChooseGrade: Bool = false
    
    // 검색 시, 선택한 화면을 판별하기 위한 Index
    private var isRecentPage: Bool = false
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabsView: TabsView!
    let buttonContainerView = UIView()
    let gradeButton = UIButton(type: .system)
    let subjectButton = UIButton(type: .system)
    
    

    //MARK: - Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        // PageController Method
        configureNavi()
        setupTabs()
        setupPageViewController()
        addBottomBorder()
        configureConstraint()
        
        // BottomPopup Setting
        configurePopupView()
        
        searchBar.delegate = self
        
        // SearchBar의 상하 선이 자동으로 생겨서 제거해주기 위한 코드
        let searchBarImage = UIImage()
        searchBar.backgroundImage = searchBarImage
        searchBar.setImage(UIImage(named: "search"), for: .search, state: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        //다른 뷰 영향 받지 않고 무조건 탭 바 보이기
        self.tabBarController?.tabBar.isHidden = false
    }

    //MARK: - Helper functions

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        // 필터링된 데이터를 변수에 넣는 과정.
        // cf) reloadData()는 불필요. 왜냐하면 이 페이지에서 데이터를 보여주지 않을 예정이므로.(전달만하면됨)
        filteredData = searchs.filter({ (search: Search) -> Bool in
            return search.title.lowercased().contains(searchText.lowercased()) || search.writer.lowercased().contains(searchText.lowercased())
        })
    }
    
    func configurePopupView() {
        gradeButton.addTarget(self, action: #selector(handelGradePopup), for: .touchUpInside)
        subjectButton.addTarget(self, action: #selector(handleSubjectPopup), for: .touchUpInside)
    }
    
    @objc func handelGradePopup() {
        let popupVC = SearchMainPopupVC()
        popupVC.mainList = .grade
        isChooseGrade = true
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func handleSubjectPopup() {
        let popupVC = SearchMainPopupVC()
        popupVC.mainList = .subject
        isChooseGrade = true
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    
        
    func configureConstraint() {
        
        let borderWidth = 2
        let borderColor = #colorLiteral(red: 1, green: 0.5102320482, blue: 0.1604259853, alpha: 1)
        
        // addSubview
        view.addSubview(buttonContainerView)
        view.addSubview(gradeButton)
        view.addSubview(subjectButton)
        view.addSubview(tabsView)
        
        // buttonContainerView Constraint
        buttonContainerView.anchor(top: searchBar.bottomAnchor,
                                   left: view.leftAnchor,
                                   right: view.rightAnchor,
                                   paddingTop: 20, height: 30)
        
        // gradeButton, subjetButton Contstraint
        // (in "buttonContainerView")
        buttonContainerView.addSubview(gradeButton)
        buttonContainerView.addSubview(subjectButton)
        
        gradeButton.setTitle("모든 학년", for: .normal)
        subjectButton.setTitle("모든 과목", for: .normal)
        
        gradeButton.setTitleColor(.black, for: .normal)
        subjectButton.setTitleColor(.black, for: .normal)
        
        
        
        gradeButton.titleLabel?.font = .appBoldFontWith(size: 13)
        gradeButton.layer.borderWidth = CGFloat(borderWidth)
        gradeButton.layer.borderColor = borderColor.cgColor
        gradeButton.layer.cornerRadius = 13
        
        subjectButton.titleLabel?.font = .appBoldFontWith(size: 13)
        subjectButton.layer.borderWidth = CGFloat(borderWidth)
        subjectButton.layer.borderColor = borderColor.cgColor
        subjectButton.layer.cornerRadius = 13
        
        gradeButton.anchor(top: buttonContainerView.topAnchor,
                           left: view.leftAnchor,
                           bottom:buttonContainerView.bottomAnchor,
                           paddingLeft: 25)
        gradeButton.setDimensions(height: buttonContainerView.frame.height, width: view.frame.width * 0.38)
        
        subjectButton.anchor(top: buttonContainerView.topAnchor,
                             bottom: buttonContainerView.bottomAnchor, right: view.rightAnchor,
                             paddingRight: 25)
        subjectButton.setDimensions(height: buttonContainerView.frame.height, width: view.frame.width * 0.38)
        
        // tabsView Contraint
        tabsView.anchor(top: buttonContainerView.bottomAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        height: 55)
        
        
    }
    
    func configureNavi() {
        let title = UILabel()
        title.text = "검색"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }
    
    func addBottomBorder() {
        let thickness: CGFloat = 0.5
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(
            x:0,
            y: self.tabsView.frame.size.height - thickness,
            width: self.tabsView.frame.size.width,
            height:thickness
            )
        bottomBorder.backgroundColor = UIColor.systemGray4.cgColor
        tabsView.layer.addSublayer(bottomBorder)
    }
        
    func setupTabs() {
        //탭 추가
        tabsView.tabs = [
            Tab(title: "인기 검색어"),
            Tab(title: "최근 검색어")
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
        self.isRecentPage = false
    }
    
    func setupPageViewController() {
        //pageViewController 설정
        self.pageController = storyboard?.instantiateViewController(withIdentifier: "TabsPageViewController") as! TabsPageViewController
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        
        //pageViewController Delegate 와 Datasource 설정
        pageController.delegate = self
        pageController.dataSource = self
        
        //앱이 시작될 때 PageViewController 에서 선택한 ViewController를 설정
        pageController.setViewControllers([showViewController(0)!], direction: .forward, animated: true, completion: nil)
        
        // 화면 전환 시, 최종 페이지 확인하기 위한 Index
        self.isRecentPage = false
        
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
        if index == 0 {
            let contentVC = PopularKeywordVC()
            contentVC.delegate = self
            contentVC.pageIndex = index
            return contentVC
        } else if index == 1 {
            let contentVC = RecentKeywordVC()
            self.delegate = contentVC
            contentVC.removeDelegate = self
            contentVC.searchKeywordRecord = self.keywordLog     // UISearchBar에서 검색한 키워드를 "최근검색어" 로 넘김
            contentVC.pageIndex = index
            return contentVC
        } else {
            let contentVC = PopularKeywordVC()
            contentVC.pageIndex = index
            return contentVC
        }
         
    }


}


//MARK: - TabsDelegate

extension SearchVC: TabsDelegate {
    func tabsViewDidSelectItemAt(position: Int) {
        //선택한 탭 셀 위치가 pageController의 현재 위치와 동일한 지 확인하고 그렇지 않은 경우 앞으로 또는 뒤로 이동
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
                
                // 화면 전환 시, 최종 페이지 확인하기 위한 Index
                self.isRecentPage = true
                
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
                
                // 화면 전환 시, 최종 페이지 확인하기 위한 Index
                self.isRecentPage = false
                
            }
            tabsView.collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}


//MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension SearchVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
        case is PopularKeywordVC:
            let vc = viewController as! PopularKeywordVC
            return vc.pageIndex
        case is RecentKeywordVC:
            let vc = viewController as! RecentKeywordVC
            return vc.pageIndex
        default:
            let vc = viewController as! PopularKeywordVC
            return vc.pageIndex
            
        }
        
    }
}


//MARK: - ProgressMainVCDelegate

extension SearchVC: ProgressPresenterDelegate {
    
    func pushCellVC(indexPath: IndexPath, progressID: String) {
        // indexPath 파라미터를 통해서 선택된 Cell에 맞는 데이터를 보여줄 예정.
        
//        let vc = ProgressDetailController(collectionViewLayout: UICollectionViewFlowLayout())
        let vc = ProgressDetailVC()
        vc.progressIdentifier = progressID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - UISearchBarDelegate

extension SearchVC: UISearchBarDelegate {
    
    // SearchBar를 클릭하여 타이핑할 때, 호출되는 메소드
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    // SearchBar의 타이핑이 끝났을 때, 호출되는 메소드
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    // 취소버튼 클릭 시, 키보드 닫기 및 검색어 초기화하는 메소드
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    // 키보드에서 검색버튼을 눌렀을 때
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.keywordLog.append(searchBar.text!)
            
        // 데이터 필터링
        filterContentForSearchText(searchBar.text!)
        
        // SearchBar 실행 시, 나타났던 키보드 및 Placeholder 초기화
        // 삭제버튼(검색어 입력할 때, 우측에 있는 x마크) 없앰.
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        // 화면이동하는 Controller로 데이터 전달
        let controller = SearchAfterVC(data: filteredData)  // TODO: 데이터를 2 번 넘기고 있음 에러수정요망
        controller.delegate = self
        controller.reloadDelegate = self
        
        // 화면 전환 시, 최근검색어 Data reLoading을 위한 로직
        pageControllForreloadData()
        
        // 화면 전환
        let vc = UINavigationController(rootViewController: controller)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    
    func pageControllForreloadData() {
        // TODO: 페이지 전환 코드
        // RecentKeywordVC의 tableView ReloadData를 위한 인스턴스 생성 로직 (다음화면 present 되는 동안 SearchVC에서 PopularKeywordVC -> RecentKeywordVC이동하며 인스턴스 생성)
        // 앱이 시작될 때 페이지 설정
        pageController.setViewControllers([showViewController(isRecentPage ? 1 : 0)!], direction: .forward, animated: false, completion: nil)
        //앱이 시작될 때 선택될 탭 설정
        tabsView.collectionView.selectItem(at: IndexPath(item: isRecentPage ? 1 : 0, section: 0), animated: true, scrollPosition: .centeredVertically)
    }
    
}

//MARK: - PopularKeywordVCDelegate
// 인기 검색어에서 검색어 클릭 시, 바로 검색결과로 이동하는 로직

extension SearchVC: PopularKeywordVCDelegate {
    func filterKeyword(keyword: String) {
        // 데이터 필터링
        filterContentForSearchText(keyword)
        self.keywordLog.append(keyword)
        // 화면전환
        let controller = SearchAfterVC(data: filteredData)
        let vc = UINavigationController(rootViewController: controller)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}


//MARK: - SearchAfterVCDelegate
// SearchAfterVC 에서 검색한 키워드를 넘겨받기 위한 Delegate.

extension SearchVC: SearchAfterVCDelegate {
    func passTheKeywordData(keyword: String) {
        self.keywordLog.append(keyword)
    }
    
    
}


//MARK: - RemoveRecentKeywordDelegate
// "최근검색어" 에서 키워드 삭제시 원본 키워드 저장소인 "keywordLog"를 삭제하기 위한 Delegation

extension SearchVC: RemoveRecentKeywordDelegate {
    func removeOriginalData(indexPath: IndexPath) {
        let path = IndexPath(row: indexPath.row, section: 0)
        self.keywordLog.remove(at: path.row)
        print("DEBUG: keywordLog is \(keywordLog)")
    }
}


extension SearchVC: ReloadDataRecentKeywordDelegate {
    func reloadTableView() {
        pageControllForreloadData()
    }
    
    
}
