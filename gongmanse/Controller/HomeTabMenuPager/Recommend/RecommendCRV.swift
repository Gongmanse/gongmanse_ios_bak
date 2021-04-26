import UIKit
import SDWebImage

class RecommendCRV: UICollectionReusableView {
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var viewTitle: UILabel!
    
    var recommendBanner: RecommendBannerImage?
    var recommendBannerImage: RecommendBannerCell?
    
    var timer = Timer()
    var counter = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        changeFontColor()
        getDataFromJson()
        
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        
//        if #available(iOS 14.0, *) {
//            self.pageView.allowsContinuousInteraction = false
//        } else {
//            //Fallback on earlier versions
//        }
        
//        pageView.numberOfPages = recommendBannerUse.data.count
        pageView.numberOfPages = 12
        pageView.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    
    func changeFontColor() {
        viewTitle.text = "추천BEST! 동영상 강의"
        
        let attributedString = NSMutableAttributedString(string: viewTitle.text!, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (viewTitle.text! as NSString).range(of: "BEST!"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (viewTitle.text! as NSString).range(of: "BEST!"))
        
        self.viewTitle.attributedText = attributedString
    }
    
    func getDataFromJson() {
        //통신
        if let url = URL(string: BannerList_URL) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(RecommendBannerImage.self, from: data) {
                    //print(json.body)
                    self.recommendBanner = json
                }
                DispatchQueue.main.async {
                    self.sliderCollectionView.reloadData()
                }
                
            }.resume()
        }
    }
    
    @objc func changeImage() {
//            if counter < images.count {
        if counter < 12 {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            pageView.currentPage = counter
            //counter = 1
        }
    }
        
}

extension RecommendCRV: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.recommendBanner?.body else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendBannerCell", for: indexPath) as! RecommendBannerCell
        guard let json = self.recommendBanner else { return cell }
        
        let indexData = json.body[indexPath.row]
        let url = URL(string: indexData.thumbnail ?? "nil")
        
        cell.bannerImage.sd_setImage(with: url)
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / self.frame.width)
        self.pageView.currentPage = page
    }
}

extension RecommendCRV: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
