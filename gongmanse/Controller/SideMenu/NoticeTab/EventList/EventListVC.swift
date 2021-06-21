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

    // 이벤트 목록이 없습니다.
    private let lectureQnALabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "이벤트 목록이 없습니다."
        return label
    }()
    
    private let emptyAlert: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "alert")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emptyStackView.isHidden = true
        collectionView.isHidden = false
        
        if eventListArray.count == 0{
            
            emptyStackView.isHidden = false
            collectionView.isHidden = true
        }
        
    }
    
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
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(lectureQnALabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
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

extension EventListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
