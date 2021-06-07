/*
 상단탭바에 대한 UI를 담당하는 View입니다.
 */


import Foundation
import UIKit

protocol VideoMenuBarDelegate: AnyObject {
    func customMenuBar(scrollTo index: Int)
}

class VideoMenuBar: UIView {
    
    let noteOffLeftImage = UIImage(named: "노트보기버튼_off")
    let qnaOffLeftImage = UIImage(named: "강의QnA버튼_off")
    let playlistOffLeftImage = UIImage(named: "재생목록버튼_off")
    
    let noteOnLeftImage = UIImage(named: "노트보기버튼_on")
    let qnaOnLeftImage = UIImage(named: "강의QnA버튼_on")
    let playlistOnLeftImage = UIImage(named: "재생목록버튼_on")
    
    public let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
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
        videoMenuBarTabBarCollectionView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.addSubview(borderLineView)
        borderLineView.anchor(left: videoMenuBarTabBarCollectionView.leftAnchor,
                              bottom: videoMenuBarTabBarCollectionView.bottomAnchor,
                              right: videoMenuBarTabBarCollectionView.rightAnchor,
                              height: 5)
    }
    
}

//MARK:- UICollectionViewDelegate, DataSource
extension VideoMenuBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoUpperCell.reusableIdentifier, for: indexPath) as! VideoUpperCell
        cell.leftImageView.tintColor = .black
        switch indexPath.row {
        case 0:
            cell.label.text = "노트보기"
            cell.leftImageView.image = noteOffLeftImage
        case 1:
            cell.label.text = "강의 QnA"
            cell.leftImageView.image = qnaOffLeftImage
        case 2:
            cell.label.text = "재생목록"
            cell.leftImageView.image = playlistOffLeftImage
        default:
            cell.label.text = "노트보기"
            cell.leftImageView.image = noteOffLeftImage
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width / 3 , height: 44)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoUpperCell else {return}

        switch indexPath.row {
        case 0:
            cell.label.text = "노트보기"
            cell.leftImageView.tintColor = .mainOrange
//            cell.leftImageView.image = noteOnLeftImage
        case 1:
            cell.label.text = "강의 QnA"
            cell.leftImageView.tintColor = .mainOrange
//            cell.leftImageView.image = qnaOnLeftImage
        case 2:
            cell.label.text = "재생목록"
            cell.leftImageView.tintColor = .mainOrange
//            cell.leftImageView.image = playlistOnLeftImage
        default:
            cell.label.text = "노트보기"
            cell.leftImageView.tintColor = .mainOrange
//            cell.leftImageView.image = noteOnLeftImage
        }
        
        delegate?.customMenuBar(scrollTo: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell2 = collectionView.cellForItem(at: indexPath) as? VideoUpperCell else {return}
        cell2.leftImageView.tintColor = .black
        
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UpperCell else {return}
//        cell.label.textColor = .mainOrange
        

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
