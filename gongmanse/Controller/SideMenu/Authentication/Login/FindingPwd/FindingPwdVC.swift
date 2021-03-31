//
//  FindingPwdVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

//import UIKit
//
//class FindingPwdVC: UIViewController {
//
//    // MARK: - Propertise
//
//
//    // MARK: - Lifecylce
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tabBarController?.tabBar.isHidden = true
//        self.navigationController?.navigationBar.isHidden = true
//        view.backgroundColor = .red
//    }
//
//}


import UIKit

class FindingPwdVC: UIViewController {

    //MARK: - Properties

    // 페이징 기능 구현을 위한 프로퍼티
    private var pageController: UIPageViewController!
    private var currentIndex: Int = 0

    
    //MARK: - IBOutlet
        
    @IBOutlet weak var tabsView: TabsView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraint()
        configureNavi()
        setupTabs()
        setupPageViewController()
    }
    
    
    //MARK: - Actions
    
    @objc func dismissVC() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper functions
    
    func configureConstraint() {
        
        // addSubview
        view.addSubview(tabsView)
        
        // tabsView Contraint
        tabsView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        paddingTop: 5,
                        height: 47)
    }
    
    func configureNavi() {
        self.tabBarController?.tabBar.isHidden = true
        
        let title = UILabel()
        title.text = "비밀번호 찾기"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        
        // navigationItem Back button
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = backButton
        
        // 그림자 효과
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1
    }
    
    func setupTabs() {
        //탭 추가
        tabsView.tabs = [
            Tab(title: "이메일로 찾기"),
            Tab(title: "휴대전화로 찾기")
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
            let contentVC = FindingPwdByEmailVC()
            contentVC.pageIndex = index
            return contentVC
        } else if index == 1 {
            let contentVC = FindingPwdByPhoneVC()
            contentVC.pageIndex = index
            return contentVC
        } else {
            let contentVC = FindingPwdByEmailVC()
            contentVC.pageIndex = index
            return contentVC
        }
        
    }
    
    
}

//MARK: - TabsDelegate

extension FindingPwdVC: TabsDelegate {
    func tabsViewDidSelectItemAt(position: Int) {
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

extension FindingPwdVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
        case is FindingPwdByEmailVC:
            let vc = viewController as! FindingPwdByEmailVC
            return vc.pageIndex
        case is FindingPwdByPhoneVC:
            let vc = viewController as! FindingPwdByPhoneVC
            return vc.pageIndex
        default:
            let vc = viewController as! FindingPwdByEmailVC
            return vc.pageIndex
            
        }
        
    }
}

