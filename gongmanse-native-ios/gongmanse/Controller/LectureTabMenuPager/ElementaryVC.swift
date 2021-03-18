//
//  ElementaryVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

private let cellId = "CurriculumCell"

class ElementaryVC: UIViewController {

    //MARK: - Properties
    
    var pageIndex: Int!
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configrueCollectionView()
    }

    //MARK: - Actions
    
    func configrueCollectionView() {
        collectionview.delegate = self
        collectionview.dataSource = self
        
        collectionview.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)

    }
    
    //MARK: - Helper functions
    
    
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ElementaryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CurriculumCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭 시 선생별 플레이리스트 화면으로 이동
        let vc = TeacherPlaylistVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.appEBFontWith(size: 17)]   // Naivagation title 폰트설정
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension ElementaryVC: UICollectionViewDelegateFlowLayout {

    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: 190)
    }

}
