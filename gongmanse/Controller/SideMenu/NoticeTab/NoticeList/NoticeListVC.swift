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
    var noticeListArray: [NoticeList] = []
    
    
    // 공지사항 목록이 없습니다.
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
        
        if noticeListArray.count == 0{
            
            emptyStackView.isHidden = false
            collectionView.isHidden = true
        }
        
    }
    
    
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
        flowlayout.itemSize = CGSize(width: collectionWidth, height: UIScreen.main.bounds.width - 40 + 70)
        
        self.collectionView.collectionViewLayout = flowlayout
        
        requestNoticeListAPI()
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(lectureQnALabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }


    func requestNoticeListAPI() {
        let getList = getNoticeList()
        getList.requestNoticeList { [weak self] result in
            self?.noticeListArray = result
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

extension NoticeListVC: UICollectionViewDelegate {
    
}

extension NoticeListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeIdentifier, for: indexPath) as? NoticeCell else { return UICollectionViewCell() }
        
        let contentImageName = noticeListArray[indexPath.row].sContent
        print("contentImageName : \(contentImageName)")
        
        //정규식
        let imageRegex = "(http(s?):\\/\\/file\\.gongmanse\\.com\\/uploads\\/editor\\/[0-9]{0,}\\/[a-z0-9]{0,}\\.(png|jpg))"
        let imageRegexDev = "(http(s?):\\/\\/filedev\\.gongmanse\\.com\\/uploads\\/editor\\/[0-9]{0,}\\/[a-z0-9]{0,}\\.(png|jpg))"
        
        var allRegex: [String] = []
        allRegex.append(contentsOf: contentImageName.getCertificationNumber(regex: imageRegex))
        
        var allRegexDev: [String] = []
        allRegexDev.append(contentsOf: contentImageName.getCertificationNumber(regex: imageRegexDev))

        if allRegex.count > 0 {// 컨탠츠 내 이미지 수량 확인
            cell.contentImage.setImageUrl(allRegex[0])
        } else if allRegexDev.count > 0 {
            cell.contentImage.setImageUrl(allRegexDev[0])
        } else {
            cell.contentImage.image = UIImage(named: "photoDefault")
        }
        
        cell.contentTitle.text = noticeListArray[indexPath.row].sTitle
        cell.contentViewer.text = noticeListArray[indexPath.row].viewer
        cell.createContentDate.text = noticeListArray[indexPath.row].dateViewer
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let noticeWebView = NoticeWebViewController(nibName: "NoticeWebViewController", bundle: nil)
        noticeWebView.noticeID = noticeListArray[indexPath.row].id
        noticeWebView.noticeAlert = true
        self.navigationController?.pushViewController(noticeWebView, animated: true)
    }
}

extension NoticeListVC: UICollectionViewDelegateFlowLayout {
    
}


