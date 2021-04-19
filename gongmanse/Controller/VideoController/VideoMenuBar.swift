/*
 상단탭바에 대한 UI를 담당하는 View입니다.
 */


import Foundation
import UIKit

protocol VideoMenuBarDelegate: class {
    func customMenuBar(scrollTo index: Int)
}

class VideoMenuBar: UIView {
    
    weak var delegate: VideoMenuBarDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupCustomTabBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoMenuBarTabBarCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    //MARK: Setup Views
    func setupCollectioView(){
        videoMenuBarTabBarCollectionView.delegate = self
        videoMenuBarTabBarCollectionView.dataSource = self
        videoMenuBarTabBarCollectionView.showsHorizontalScrollIndicator = false
        videoMenuBarTabBarCollectionView.register(VideoUpperCell.self, forCellWithReuseIdentifier: VideoUpperCell.reusableIdentifier)
        videoMenuBarTabBarCollectionView.isScrollEnabled = false
        
        let indexPath = IndexPath(item: 0, section: 0)
        videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
    
    func setupCustomTabBar(){
        setupCollectioView()
        self.addSubview(videoMenuBarTabBarCollectionView)
        videoMenuBarTabBarCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        videoMenuBarTabBarCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        videoMenuBarTabBarCollectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        videoMenuBarTabBarCollectionView.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }
    
}

//MARK:- UICollectionViewDelegate, DataSource
extension VideoMenuBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoUpperCell.reusableIdentifier, for: indexPath) as! VideoUpperCell
        
        switch indexPath.row {
        case 0:
            cell.label.text = "노트보기"
        case 1:
            cell.label.text = "강의 QnA"
        case 2:
            cell.label.text = "재생목록"
        default:
            cell.label.text = "노트보기"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width / 3 , height: 55)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.customMenuBar(scrollTo: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? UpperCell else {return}
        cell.label.textColor = .mainOrange
    }
}
//MARK:- UICollectionViewDelegateFlowLayout
extension VideoMenuBar: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
