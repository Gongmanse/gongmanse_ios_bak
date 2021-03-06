import UIKit
import SideMenu
import AVKit

class HomeVC: UIViewController {

    var koreanEnglishMathSelectedIndex: Int = 0
    var koreanEnglishMathSortedIndex: Int = 0
    var scienceSelectedIndex: Int = 0
    var scienceSortedIndex: Int = 0
    var socialStudiesSelectedIndex: Int = 0
    var socialStudiesSortedIndex: Int = 0
    var otherSubjectsSelectedIndex: Int = 0
    var otherSubjectsSortedIndex: Int = 0
    
    @IBOutlet weak var tabsView: TabsView!
    
    var currentIndex: Int = 0
    
    var pageController: UIPageViewController!
    
    var contentVC1: RecommendVC! = nil
    var contentVC2: PopularVC! = nil
    var contentVC3: KoreanEnglishMathVC! = nil
    var contentVC4: ScienceVC! = nil
    var contentVC5: SocialStudiesVC! = nil
    var contentVC6: OtherSubjectsVC! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white

        setupTabs()
        setupPageViewController()
        
        addBottomBorder()
        
        // 탭 리스트 자동재생 시 audio session 제어
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("HomeVC viewDidAppear")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("HomeVC viewWillAppear")
        //네비게이션 바 타이틀에 공만세 이미지 적용
        let image = UIImage(named: "main_logo")
        let iv = UIImageView(image: image)
        if UIDevice.current.userInterfaceIdiom == .pad {
            iv.transform = CGAffineTransform(scaleX: 1.44, y: 1.44)
        }
        navigationItem.titleView = iv
        
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

        //다른 뷰 영향 받지 않고 무조건 탭 바 보이기
        self.tabBarController?.tabBar.isHidden = false
        
        // 비디오 로그 초기화 하도록 적용
        let videoLog = VideoDataManager.shared.videoPlayIDLog
        print("videoLog.count : \(videoLog.count)")
        if videoLog.count > 0 {
            for _ in 0..<videoLog.count {
                VideoDataManager.shared.removeVideoLastLog()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("HomeVC viewDidDisappear")
        Constant.delegate = nil
    }
    
    func addBottomBorder() {
        let thickness: CGFloat = 0.5
       let bottomBorder = CALayer()
       bottomBorder.frame = CGRect(x:0, y: self.tabsView.frame.size.height - thickness, width: UIScreen.main.bounds.width, height:thickness)
       bottomBorder.backgroundColor = UIColor.systemGray4.cgColor
       tabsView.layer.addSublayer(bottomBorder)
    }
    
    func setupTabs() {
        //탭 추가
        tabsView.tabs = [
            Tab(title: "추천"),
            Tab(title: "인기"),
            Tab(title: "국영수"),
            Tab(title: "과학"),
            Tab(title: "사회"),
            Tab(title: "기타")
        ]
        
        //TabMode를 화면 전체 너비로 확장 된 탭의 경우 '.fixed'로 설정하고 모든 탭을 보려면 스크롤하려면 '.scrollable'로 설정
        tabsView.tabMode = .fixed
        
        //TabView 커스텀
        tabsView.titleColor = .black
        tabsView.indicatorColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        if UIDevice.current.userInterfaceIdiom == .pad {
            tabsView.titleFont = UIFont.boldSystemFont(ofSize: 20)
        } else {
            tabsView.titleFont = UIFont.boldSystemFont(ofSize: 18)
        }
        tabsView.collectionView.backgroundColor = .white
        
        //TabsView Delegate 설정
        tabsView.delegate = self
        
        //앱이 시작될 때 선택될 탭 설정
        tabsView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
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
            if contentVC1 == nil {
                contentVC1 = storyboard?.instantiateViewController(withIdentifier: "RecommendVC") as? RecommendVC
            }
            contentVC1.pageIndex = index
            return contentVC1
        } else if index == 1 {
            if contentVC2 == nil {
                contentVC2 = storyboard?.instantiateViewController(withIdentifier: "PopularVC") as? PopularVC
            }
            contentVC2.pageIndex = index
            return contentVC2
        } else if index == 2 {
            // 국영수
            if contentVC3 == nil {
                contentVC3 = storyboard?.instantiateViewController(withIdentifier: "KoreanEnglishMathVC") as? KoreanEnglishMathVC
            }
            contentVC3.delegate = self
            contentVC3.selectedItem = koreanEnglishMathSelectedIndex
            contentVC3.sortedId = koreanEnglishMathSortedIndex
            contentVC3.pageIndex = index
            return contentVC3
        } else if index == 3 {
            // 과학
            if contentVC4 == nil {
                contentVC4 = storyboard?.instantiateViewController(withIdentifier: "ScienceVC") as? ScienceVC
            }
            contentVC4.delegate = self
            contentVC4.selectedItem = scienceSelectedIndex
            contentVC4.sortedId = scienceSortedIndex
            contentVC4.pageIndex = index
            return contentVC4
        } else if index == 4 {
            // 사회
            if contentVC5 == nil {
                contentVC5 = storyboard?.instantiateViewController(withIdentifier: "SocialStudiesVC") as? SocialStudiesVC
            }
            contentVC5.delegate = self
            contentVC5.selectedItem = socialStudiesSelectedIndex
            contentVC5.sortedId = socialStudiesSortedIndex
            contentVC5.pageIndex = index
            return contentVC5
        } else {
            // 기타 과목
            if contentVC6 == nil {
                contentVC6 = storyboard?.instantiateViewController(withIdentifier: "OtherSubjectsVC") as? OtherSubjectsVC
            }
            contentVC6.delegate = self
            contentVC6.selectedItem = otherSubjectsSelectedIndex
            contentVC6.sortedId = otherSubjectsSortedIndex
            contentVC6.pageIndex = index
            return contentVC6
//        } else {
//            let contentVC = storyboard?.instantiateViewController(withIdentifier: "RecommendVC") as! RecommendVC
//            contentVC.pageIndex = index
//            return contentVC
        }
    }
}

extension HomeVC: TabsDelegate {
    func tabsViewDidSelectItemAt(position: Int) {
        //선택한 탭 셀 위치가 pageController의 현재 위치와 동일한 지 확인하고 그렇지 않은 경우 앞으로 또는 뒤로 이동
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: false, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: false, completion: nil)
            }
            tabsView.collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

extension HomeVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
        case is RecommendVC:
            let vc = viewController as! RecommendVC
            return vc.pageIndex
        case is PopularVC:
            let vc = viewController as! PopularVC
            return vc.pageIndex
        case is KoreanEnglishMathVC:
            let vc = viewController as! KoreanEnglishMathVC
            vc.delegate = self
            vc.selectedItem = koreanEnglishMathSelectedIndex
            vc.sortedId = koreanEnglishMathSortedIndex
            return vc.pageIndex
        case is ScienceVC:
            let vc = viewController as! ScienceVC
            vc.delegate = self
            vc.selectedItem = scienceSelectedIndex
            vc.sortedId = scienceSortedIndex
            return vc.pageIndex
        case is SocialStudiesVC:
            let vc = viewController as! SocialStudiesVC
            vc.delegate = self
            vc.selectedItem = socialStudiesSelectedIndex
            vc.sortedId = socialStudiesSortedIndex
            return vc.pageIndex
        case is OtherSubjectsVC:
            let vc = viewController as! OtherSubjectsVC
            vc.delegate = self
            vc.selectedItem = otherSubjectsSelectedIndex
            vc.sortedId = otherSubjectsSortedIndex
            return vc.pageIndex
        default:
            let vc = viewController as! RecommendVC
            return vc.pageIndex
        }
    }
}

//border 넣기
extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}


extension HomeVC: KoreanEnglishMathVCDelegate, ScienceVCDelegate, SocialStudiesVCDelegate, OtherSubjectsVCDelegate {
    
    func koreanPassSortedIdSettingValue(_ sortedIndex: Int) {
        self.koreanEnglishMathSortedIndex = sortedIndex
    }
    
    func koreanPassSelectedIndexSettingValue(_ selectedIndex: Int) {
        self.koreanEnglishMathSelectedIndex = selectedIndex
    }
    
    func sciencePassSortedIdSettingValue(_ sortedIndex: Int) {
        self.scienceSortedIndex = sortedIndex
    }
    
    func sciencePassSelectedIndexSettingValue(_ selectedIndex: Int) {
        self.scienceSelectedIndex = selectedIndex
    }
    
    func socialStudiesPassSortedIdSettingValue(_ sortedIndex: Int) {
        self.socialStudiesSortedIndex = sortedIndex
    }
    
    func socialStudiesPassSelectedIndexSettingValue(_ selectedIndex: Int) {
        self.socialStudiesSelectedIndex = selectedIndex
    }
    
    func otherSubjectsPassSortedIdSettingValue(_ sortedIndex: Int) {
        self.otherSubjectsSortedIndex = sortedIndex
    }
    
    func otherSubjectsPassSelectedIndexSettingValue(_ selectedIndex: Int) {
        self.otherSubjectsSelectedIndex = selectedIndex
    }
}

