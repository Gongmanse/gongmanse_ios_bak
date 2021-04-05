//
//  NoticeListVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit

class NoticeListVC: UIViewController {

    var pageIndex = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    let NoticeIdentifier = "NoticeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        let nibName = UINib(nibName: NoticeIdentifier, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: NoticeIdentifier)
        
        let flowlayout: UICollectionViewFlowLayout
        flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.zero
        
        flowlayout.minimumInteritemSpacing = 10
        
        let collectionWidth = UIScreen.main.bounds.width
        flowlayout.itemSize = CGSize(width: collectionWidth, height: 234)
        
        self.collectionView.collectionViewLayout = flowlayout
    }


}

extension NoticeListVC: UICollectionViewDelegate {
    
}

extension NoticeListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeIdentifier, for: indexPath) as? NoticeCell else { return UICollectionViewCell() }
        
        cell.contentImage.image = UIImage(named: "five")
        cell.contentTitle.text = "AA"
        cell.contentViewer.text = "2"
        cell.createContentDate.text = "2017.02.12"
        
        return cell
    }
}

extension NoticeListVC: UICollectionViewDelegateFlowLayout {
    
}
