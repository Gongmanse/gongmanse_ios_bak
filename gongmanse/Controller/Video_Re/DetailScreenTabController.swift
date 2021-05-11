//
//  DetailScreenTabController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import UIKit

class DetailScreenTabController: UIViewController{

    // MARK: - Properties
    
    var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var detailScreenTabBar = DetailScreenTabBarView()

    /// 강의 및 선생님 정보를 담을 뷰
    let lessonInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Heleprs
    
    func configureUI() {
        configureConstraint()
        setupPageCollectionView()
        view.backgroundColor = .clear
    }
    
    func configureConstraint() {
        view.addSubview(detailScreenTabBar)
        detailScreenTabBar.delegate = self
        detailScreenTabBar.setDimensions(height: 44, width: view.frame.width)
        detailScreenTabBar.anchor(top: view.topAnchor,
                                  left: view.leftAnchor)
        
        view.addSubview(lessonInfoView)
        lessonInfoView.setDimensions(height: 230, width: view.frame.width)
        lessonInfoView.centerX(inView: view)
        lessonInfoView.anchor(top: detailScreenTabBar.bottomAnchor)
        
        view.addSubview(pageCollectionView)
        pageCollectionView.centerX(inView: detailScreenTabBar)
        pageCollectionView.anchor(top: lessonInfoView.bottomAnchor,
                                  bottom: view.bottomAnchor,
                                  width: view.frame.width)
    }
    
    func setupPageCollectionView(){
        pageCollectionView.isScrollEnabled = false
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.backgroundColor = .white
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.isPagingEnabled = true
        pageCollectionView.register(DetailScreenNotecell.self,
                                    forCellWithReuseIdentifier: DetailScreenNotecell.reusableIdentifier)
        pageCollectionView.register(DetailScreenQnACell.self,
                                    forCellWithReuseIdentifier: DetailScreenQnACell.reusableIdentifier)
        pageCollectionView.register(DetailScreenPlaylistCell.self,
                                    forCellWithReuseIdentifier: DetailScreenPlaylistCell.reusableIdentifier)
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource

extension DetailScreenTabController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailScreenNotecell.reusableIdentifier,for: indexPath) as! DetailScreenNotecell
            cell.layoutIfNeeded()
            let noteVC = NoteController()
            self.addChild(noteVC)
            noteVC.didMove(toParent: self)
            cell.contentView.addSubview(noteVC.view)
            noteVC.view.anchor(top: cell.contentView.topAnchor,
                               left: cell.contentView.leftAnchor,
                               bottom: cell.contentView.bottomAnchor,
                               right: cell.contentView.rightAnchor)
            noteVC.view.layoutIfNeeded()
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailScreenQnACell.reusableIdentifier, for: indexPath) as! DetailScreenQnACell
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailScreenPlaylistCell.reusableIdentifier, for: indexPath) as! DetailScreenPlaylistCell
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailScreenNotecell.reusableIdentifier,for: indexPath) as! DetailScreenNotecell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { return 3 }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt, section: 0)
        detailScreenTabBar.videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout

extension DetailScreenTabController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailScreenTabController: DetailScreenTabBarViewDelegate {
    func customMenuBar(scrollTo index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
