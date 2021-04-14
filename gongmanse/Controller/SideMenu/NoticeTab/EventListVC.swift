//
//  EventListVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit

class EventListVC: UIViewController {

    
    var pageIndex = 0
    private let EventListCellIdentifier = "EventListCell"
    private var eventListArray: [EventModel] = []
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.showsVerticalScrollIndicator = false
        
        let nibName = UINib(nibName: EventListCellIdentifier, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: EventListCellIdentifier)
        
        let flowlayout: UICollectionViewFlowLayout
        flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets.zero
        
        flowlayout.minimumInteritemSpacing = 10
        
        let collectionWidth = UIScreen.main.bounds.width
        flowlayout.itemSize = CGSize(width: collectionWidth, height: 234)
        
        self.collectionView.collectionViewLayout = flowlayout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        requestEventListAPI()
    }

    func requestEventListAPI() {
        let getList = RequestEventListAPI(offset: 0)
        getList.getRequestEvent(complition: { [weak self] result in
            self?.eventListArray = result
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        })
    }
    
}
extension EventListVC: UICollectionViewDelegate {
    
}
extension EventListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventListCellIdentifier, for: indexPath) as? EventListCell else { return UICollectionViewCell() }
        
        let thumbNailURL = eventListArray[indexPath.row].sThumbnail
        let imageURL = "\(fileBaseURL)/\(thumbNailURL)"
        cell.contentImage.setImageUrl(imageURL)
        cell.contentTitle.text = eventListArray[indexPath.row].sTitle
        cell.contentViewer.text = eventListArray[indexPath.row].viewer
        cell.contentCreateDate.text = eventListArray[indexPath.row].dateViewer
        cell.isDisplayStats.text = "표시 전"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let noticeWebView = NoticeWebViewController(nibName: "NoticeWebViewController", bundle: nil)
        noticeWebView.noticeID = eventListArray[indexPath.row].id
        noticeWebView.eventAlert = true
        self.navigationController?.pushViewController(noticeWebView, animated: true)
    }
}
