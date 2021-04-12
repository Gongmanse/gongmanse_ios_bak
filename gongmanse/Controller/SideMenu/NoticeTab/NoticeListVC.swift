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
        let url = URL(string: allRegex[0])
        do {
            let data = try Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.contentImage.image = UIImage(data: data)
            }
        }catch{
            print("Data Err, ", error.localizedDescription)
        }
        
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
//extension String{
//
//    func getArrayAfterRegex(regex: String, text: String) -> [String] {
//
//            do {
//                let regex = try NSRegularExpression(pattern: regex)
//                let results = regex.matches(in: text,
//                                            range: NSRange(text.startIndex..., in: text))
//                return results.map {
//                    String(text[Range($0.range, in: text)!])
//                }
//            } catch let error {
//                print("invalid regex: \(error.localizedDescription)")
//                return []
//            }
//        }
//
//}

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
