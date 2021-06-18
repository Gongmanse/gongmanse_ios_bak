import UIKit
import SDWebImage
import Alamofire

class RecommendVC: UIViewController {
    
    var pageIndex: Int!
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    var loadingView: FooterCRV?
    var isLoading = false
    
    var recommendVideo = VideoInput(header: HeaderData.init(resultMsg: "", totalRows: "", isMore: ""), body: [VideoModels]())
    
    var recommendVideoSecond: BeforeApiModels?
    
    let recommendRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var recommendCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendCollection.refreshControl = recommendRC
        
        getDataFromJson()
        getDataFromJsonSecond()
        
    }
    
    //API
    var default1 = 0

    func getDataFromJson() {
        if let url = URL(string: makeStringKoreanEncoded(Recommend_Video_URL + "/모든?offset=\(default1)&limit=20")) {
            default1 += 20
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //print(json.body)
//                    self.recommendVideo = json
                    self.recommendVideo.body.append(contentsOf: json.body)
                    /**
                     06.14
                     자동재생을 on 했을 때, 추천에 나타난 데이터를 활용하기 위해 싱글톤을 사용했습니다.
                     */
                    let autoPlayDataManager = AutoplayDataManager.shared
                    autoPlayDataManager.videoDataInRecommandTab? = json
                }
                DispatchQueue.main.async {
                    self.recommendCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    func getDataFromJsonSecond() {
        if let url = URL(string: "https://api.gongmanse.com/v/video/recommendvid?offset=\(default1)&limit=20") {
            default1 += 20
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(BeforeApiModels?.self, from: data) {
                    //print(json.body)
                    self.recommendVideoSecond = json
                }
                DispatchQueue.main.async {
                    self.recommendCollection.reloadData()
                }

            }.resume()
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        getDataFromJson()
        sender.endRefreshing()
        recommendCollection.reloadData()
    }
}

extension RecommendVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let data = self.recommendVideo?.data else { return 0}
        let recommendData = self.recommendVideo
        return recommendData.body.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCVCell", for: indexPath) as! RecommendCVCell
//        guard let json = self.recommendVideo else { return cell }
        
        let json = self.recommendVideo
        let indexData = json.body[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(indexData.thumbnail ?? "nil"))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoThumbnail.sizeToFit()
        cell.videoTitle.text = indexData.title
        cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
        cell.subjects.text = indexData.subject
        cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
        cell.starRating.text = indexData.rating
        
        if indexData.unit != nil {
            cell.term.isHidden = false
            cell.term.text = indexData.unit
        } else if indexData.unit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData.unit == "2" {
            cell.term.isHidden = false
            cell.term.text = "ii"
        } else {
            cell.term.isHidden = true
        }
        return cell
    }
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(2)
                
                DispatchQueue.main.async {
                    self.recommendCollection.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RecommendCRV", for: indexPath) as? RecommendCRV else {
                return UICollectionReusableView()
            }
            header.delegate = self
            return header
        case UICollectionView.elementKindSectionFooter:
            if kind == UICollectionView.elementKindSectionFooter {
                let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath) as! FooterCRV
                
                loadingView = aFooterView
                loadingView?.backgroundColor = UIColor.clear
                return aFooterView
            }
            return UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: recommendCollection.bounds.size.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.indicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.indicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.recommendVideo.body.count - 20 && !self.isLoading {
            loadMoreData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position == (recommendCollection.contentSize.height - scrollView.frame.size.height) {
//            /// TODO: 로딩인디케이터
//            UIView.animate(withDuration: 3) {
//                // 로딩이미지
//            } completion: { (_) in
//                // API 호출
//            }
            getDataFromJson()
            recommendCollection.reloadData()
        }
    }
}

extension RecommendVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // 토큰이 없는 경우
        // -> 추천 동영상 비디오 경로 API & 추천 동영상 비디오 노트 API를 호출한다.
        if Constant.isGuestKey || Constant.remainPremiumDateInt == nil  {
            print("DEBUG: 게스트로입장")
            Constant.token = ""
            presentVideoController(indexPath.row)
//            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        } else {
            // 이용권이 있는 계정으로 로그인
            presentVideoController(indexPath.row)
        }
    }
    
    /// 클릭한 cell의 indexPath.row를 입력받아 VideoController를 호출하는 메소드
    func presentVideoController(_ selectedRow: Int) {
        
        let vc = VideoController()
        let videoDataManager = VideoDataManager.shared
        videoDataManager.isFirstPlayVideo = true
        vc.delegate = self
        vc.id = recommendVideo.body[selectedRow].videoId
        vc.modalPresentationStyle = .fullScreen
        vc.recommendReceiveData = recommendVideo
        autoPlayDataManager.currentViewTitleView = "추천"
        self.present(vc, animated: true)
    }
}


extension RecommendVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: 265)
    }
}


extension RecommendVC: RecommendCRVDelegate {
    func presentVideoControllerInBanner(videoID: String) {
        
        let vc = VideoController()
        let videoDataManager = VideoDataManager.shared
        videoDataManager.isFirstPlayVideo = true
        vc.delegate = self
        vc.id = videoID
        vc.modalPresentationStyle = .fullScreen
        vc.recommendReceiveData = recommendVideo
        autoPlayDataManager.currentViewTitleView = "추천"
        self.present(vc, animated: true)
    }
    
    
}

extension RecommendVC: VideoControllerDelegate {
    
    func recommandVCPresentVideoVC() {
        let vc = VideoController()
        vc.modalPresentationStyle = .fullScreen
        vc.id = "15188"
        self.present(vc, animated: false)
    }
    
    
}
