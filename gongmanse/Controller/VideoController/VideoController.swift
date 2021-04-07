/*
 "영상" 페이지 전체를 컨트롤하는 Controller 입니다.
 * 상단 탭바를 담당하는 객체: VideoMenuBar
 * 상단 탭바의 각각의 항목을 담당하는 객체: TabBarCell 폴더 내부 객체
 * 하단 "노트보기", "강의 QnA" 그리고 "재생목록"을 담당하는 객체: BottomCell 폴더 내부 객체
 */

import Foundation
import UIKit

class VideoController: UIViewController, VideoMenuBarDelegate{
    
    // MARK: - Properties
    
    private var teacherInfoFoldConstraint: NSLayoutConstraint?     // 최초적용될 제약조건
    private var teacherInfoUnfoldConstraint: NSLayoutConstraint?  // 클릭 시, 적용될 제약조건
    
    // 영상객체 생성
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 가로방향으로 스크롤할 수 있도록 구현한 CollectionView
    var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // 상단 탭바 객체 생성
    var customMenuBar = VideoMenuBar()
    
    // 선생님 정보 View 객체 생성
    private let teacherInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히보기", for: .normal)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupCustomTabBar()
        setupPageCollectionView()
        configureToggleButton()
        
    }
    
    // MARK: - Actions
    
    @objc func handleToggle() {
        if teacherInfoFoldConstraint?.isActive == true {
            teacherInfoFoldConstraint?.isActive = false
            teacherInfoUnfoldConstraint?.isActive = true
            pageCollectionView.reloadData()
        } else {
            teacherInfoFoldConstraint?.isActive = true
            teacherInfoUnfoldConstraint?.isActive = false
            pageCollectionView.reloadData()
        }
        
    }
    
    
    // MARK: - Helpers
        
    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        navigationController?.hidesBarsOnSwipe = true
        
        // 영상View
        view.addSubview(videoContainerView)
        videoContainerView.setDimensions(height: view.frame.height * 0.36,
                                         width: view.frame.width)
        videoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        videoContainerView.centerX(inView: view)
        
        // 선생님정보 View
    }
    
    func setupCustomTabBar(){
        self.view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        customMenuBar.anchor(top: videoContainerView.bottomAnchor,
                             left: view.leftAnchor)
        customMenuBar.setDimensions(height: view.frame.height * 0.06, width: view.frame.width)
//        customMenuBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        customMenuBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        customMenuBar.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor).isActive = true
//        customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06).isActive = true
        
        view.addSubview(teacherInfoView)
//        teacherInfoView.setDimensions(height: view.frame.height * 0.167, width: view.frame.width)
        teacherInfoFoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: 0)
        teacherInfoUnfoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.28)
        
        
        teacherInfoView.centerX(inView: videoContainerView)
        teacherInfoView.anchor(top: customMenuBar.bottomAnchor,
                               width: view.frame.width)
        teacherInfoFoldConstraint?.isActive = true
        
        
        
    }
    
    func customMenuBar(scrollTo index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func setupPageCollectionView(){
        pageCollectionView.isScrollEnabled = false
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.backgroundColor = .white
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.isPagingEnabled = true
        pageCollectionView.register(BottomNoteCell.self, forCellWithReuseIdentifier: BottomNoteCell.reusableIdentifier)
        pageCollectionView.register(BottomQnACell.self, forCellWithReuseIdentifier: BottomQnACell.reusableIdentifier)
        pageCollectionView.register(BottomPlaylistCell.self, forCellWithReuseIdentifier: BottomPlaylistCell.reusableIdentifier)
        self.view.addSubview(pageCollectionView)
        pageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pageCollectionView.topAnchor.constraint(equalTo: self.teacherInfoView.bottomAnchor).isActive = true
    }
    
    
    func configureToggleButton() {
        view.addSubview(toggleButton)
        toggleButton.setDimensions(height: 20, width: 20)
        toggleButton.anchor(top: teacherInfoView.bottomAnchor,
                            right: teacherInfoView.rightAnchor,
                            paddingRight: 10)
        toggleButton.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
    }
    
    
}
//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension VideoController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomQnACell.reusableIdentifier, for: indexPath) as! BottomQnACell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomPlaylistCell.reusableIdentifier, for: indexPath) as! BottomPlaylistCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt, section: 0)
        customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}
//MARK:- UICollectionViewDelegateFlowLayout
extension VideoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
