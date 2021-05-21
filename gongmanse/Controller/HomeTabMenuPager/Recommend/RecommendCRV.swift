import UIKit
import SDWebImage

protocol RecommendCRVDelegate: AnyObject {
    func presentVideoControllerInBanner(videoID: String)
}

class RecommendCRV: UICollectionReusableView {
    
    weak var delegate: RecommendCRVDelegate?
    
    private var timer: Timer?
    private var onlyOnce = true
    
    var recommendBanner: RecommendBannerImage?
    var recommendBannerImage: RecommendBannerCell?
    let infiniteSize = 96
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var viewTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeFontColor()
        getDataFromJson()
        
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        
        pageView.numberOfPages = 12
        pageView.currentPage = 0
        pageView.isEnabled = false
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
                    self.recommendBanner = json
                }
                DispatchQueue.main.async {
                    self.sliderCollectionView.reloadData()
                }
                
            }.resume()
        }
    }
    
    @objc func changeImage() {
        
        guard let currentItemNumber = sliderCollectionView.indexPathsForVisibleItems.first?.item else { return }
        let nextItemNumber = currentItemNumber + 1
        let nextIndexPath = IndexPath(item: nextItemNumber, section: 0)
        sliderCollectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
    }
}

extension RecommendCRV: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return infiniteSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendBannerCell", for: indexPath) as! RecommendBannerCell
        guard let json = self.recommendBanner else { return cell }
        guard let data = self.recommendBanner?.body else { return UICollectionViewCell()}
        
        let indexData = json.body[indexPath.row % data.count]
        let url = URL(string: indexData.thumbnail ?? "nil")
        
        cell.bannerImage.sd_setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if onlyOnce {
            let middleIndex = IndexPath(item: Int(infiniteSize / 2), section: 0)
            sliderCollectionView.scrollToItem(at: middleIndex, at: .centeredHorizontally, animated: false)
            startTimer()
            onlyOnce = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerData = self.recommendBanner {
            print("DEBUG: 받아온 데이터의 개수입니다. \(bannerData.body.count)")
            print("DEBUG: 클릭한 아이템 데이터입니다. \(indexPath.row)")
            
//            if let videoID = bannerData.body[indexPath.item].videoId {
//                delegate?.presentVideoControllerInBanner(videoID: videoID)
//            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func updatePageControl(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.bounds.size.width)
        guard let count = self.recommendBanner?.body.count else { return }
        let currentPageNumber = Int(pageNumber) % count
        pageView.currentPage = currentPageNumber
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        startTimer()
    }
}

extension RecommendCRV: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
