import UIKit

class CustomerServiceVC: UIViewController {

    @IBOutlet weak var tabsView: TabsView!
    var pageViewContoller: UIPageViewController!
    var currentIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationSetting()
        setupTabs()
        setupPageViewController()
        
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

            let contentVC = FrequentlyAskViewContoler(nibName: "FrequentlyAskViewContoler", bundle: nil)
            contentVC.pageIndex = index
            return contentVC
        } else if index == 1 {

            let contentVC = OneonOneEnquiryViewController(nibName: "OneonOneEnquiryViewController", bundle: nil)
            contentVC.pageIndex = index
            return contentVC
        } else {

            let contentVC = FrequentlyAskViewContoler(nibName: "FrequentlyAskViewContoler", bundle: nil)
            contentVC.pageIndex = index
            return contentVC
        }
    }
}

//MARK: - CustomerService 설정관련

extension CustomerServiceVC {

    func navigationSetting() {
        
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "고객센터"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    
    func setupTabs() {
        //탭 추가
        tabsView.tabs = [
            Tab(title: "자주묻는질문"),
            Tab(title: "1:1 문의")
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
        //pageViewController 설정
        self.pageViewContoller = storyboard?.instantiateViewController(withIdentifier: "TabsPageViewController") as? TabsPageViewController
        self.addChild(self.pageViewContoller)
        self.view.addSubview(self.pageViewContoller.view)
        
        //pageViewController Delegate 와 Datasource 설정
        pageViewContoller.delegate = self
        pageViewContoller.dataSource = self
        
        //앱이 시작될 때 PageViewController 에서 선택한 ViewController를 설정
        pageViewContoller.setViewControllers([showViewController(0)!], direction: .forward, animated: true, completion: nil)
        
        //pageViewController 제약조건 추가
        self.pageViewContoller.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.pageViewContoller.view.topAnchor.constraint(equalTo: self.tabsView.bottomAnchor),
            self.pageViewContoller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pageViewContoller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pageViewContoller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.pageViewContoller.didMove(toParent: self)
    }
}
//MARK: - 상단 tap시 뷰컨도 같이 move
extension CustomerServiceVC: TabsDelegate {
    func tabsViewDidSelectItemAt(position: Int) {
        //선택한 탭 셀 위치가 pageController의 현재 위치와 동일한 지 확인하고 그렇지 않은 경우 앞으로 또는 뒤로 이동
        if position != currentIndex {
            if position > currentIndex {
                self.pageViewContoller.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageViewContoller.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
            tabsView.collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

//MARK: - page 관련

extension CustomerServiceVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    //앞으로 갈 때 viewController 반환
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = viewControllerPageIndex(vc)
        
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
        index = viewControllerPageIndex(vc)
        
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
                
                index = viewControllerPageIndex(vc)
                
                tabsView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
                
                //scrollable을 사용하여 스크롤 할 때 TabsView의 탭을 중앙에 표시
                tabsView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    //UIPageViewController 에있는 UIViewController에 저장된 현재 위치를 반환
    func viewControllerPageIndex(_ viewController: UIViewController?) -> Int {
        switch viewController {
        case is FrequentlyAskViewContoler:
            guard let vc = viewController as? FrequentlyAskViewContoler else { return 0}
            return vc.pageIndex
            
        case is OneonOneEnquiryViewController:
            guard let vc = viewController as? OneonOneEnquiryViewController else { return 0}
            return vc.pageIndex
            
        default:
            guard let vc = viewController as? FrequentlyAskViewContoler else { return 0}
            return vc.pageIndex
        }
    }
}
