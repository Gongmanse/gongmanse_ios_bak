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
        
        pageView.numberOfPages = 3
        pageView.currentPage = 0
        pageView.isEnabled = false
    }
    
    func changeFontColor() {
        viewTitle.text = "추천BEST! 동영상 강의"
        
        let attributedString = NSMutableAttributedString(string: viewTitle.text!, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .medium), range: (viewTitle.text! as NSString).range(of: "BEST!"))
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
                    DispatchQueue.main.async {
                        self.pageView.numberOfPages = json.body.count
                    }
                }
                DispatchQueue.main.async {
                    self.sliderCollectionView.reloadData()
                }
                
            }.resume()
        }
    }
    
    // AOS와 동일한 구조로 좌우 반복 형태로 변경
    var clockWise = true
    @objc func changeImage() {
        guard let currentItemNumber = sliderCollectionView.indexPathsForVisibleItems.first?.item else { return }
        guard let count = self.recommendBanner?.body.count else { return }
        var nextItemNumber: Int
        if clockWise {
            nextItemNumber = currentItemNumber + 1
            if nextItemNumber == count ||
                nextItemNumber == 2 * count {
                clockWise = !clockWise
                changeImage()
                return
            }
        } else {
            nextItemNumber = currentItemNumber - 1
            if nextItemNumber == -1 ||
                nextItemNumber == count - 1 {
                clockWise = !clockWise
                changeImage()
                return
            }
        }
        let nextIndexPath = IndexPath(item: nextItemNumber, section: 0)
        sliderCollectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
    }
}

extension RecommendCRV: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let bannerCount = recommendBanner?.body.count else { return 0 }
        return 2 * bannerCount
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
            sliderCollectionView.scrollToItem(at: [0, self.recommendBanner!.body.count], at: .left, animated: false)
            
            startTimer()
            onlyOnce = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerData = self.recommendBanner {
            if let videoID = bannerData.body[indexPath.row % bannerData.body.count].videoId {
                delegate?.presentVideoControllerInBanner(videoID: videoID)
            }
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

        guard let count = self.recommendBanner?.body.count else { return }
        
        // 무한스크롤을 위해 스크롤 종료 시 애니메이션 없이 좌표 이동
        guard let currentItemNumber = sliderCollectionView.indexPathsForVisibleItems.first?.item else { return }
        switch currentItemNumber {
        case 0:
            sliderCollectionView.scrollToItem(at: [0, count], at: .left, animated: false)
        case 2 * count - 1:
            sliderCollectionView.scrollToItem(at: [0, count - 1], at: .left, animated: false)
        default:
            break
        }
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
        //0707 - edited by hp
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.width / 16 * 9)
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
