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
        
        requestNoticeListAPI()
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
        
        //정규식
        let head = "(http(s?):\\/\\/file\\.gongmanse\\.com\\/uploads\\/editor\\/96\\/[a-z0-9]{0,}\\.(png|jpg))"
        
        var allRegex: [String] = []
        allRegex.append(contentsOf: contentImageName.getArrayAfterRegex(regex: head))
        
        print(allRegex[0])

        cell.contentImage.setImageUrl(allRegex[0])
        cell.contentTitle.text = noticeListArray[indexPath.row].sTitle
        cell.contentViewer.text = noticeListArray[indexPath.row].viewer
        cell.createContentDate.text = noticeListArray[indexPath.row].dateViewer
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let noticeWebView = NoticeWebViewController(nibName: "NoticeWebViewController", bundle: nil)

        self.navigationController?.pushViewController(noticeWebView, animated: true)
    }
}

extension NoticeListVC: UICollectionViewDelegateFlowLayout {
    
}

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension UIImageView {
    func setImageUrl(_ url: String) {
            
            let cacheKey = NSString(string: url) // 캐시에 사용될 Key 값
            
            if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) { // 해당 Key 에 캐시이미지가 저장되어 있으면 이미지를 사용
                self.image = cachedImage
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                if let imageUrl = URL(string: url) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, res, err) in
                        if let _ = err {
                            DispatchQueue.main.async {
                                self.image = UIImage()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data) {
                                ImageCacheManager.shared.setObject(image, forKey: cacheKey) // 다운로드된 이미지를 캐시에 저장
                                self.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
}
