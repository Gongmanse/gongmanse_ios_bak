import UIKit
import SDWebImage
import Alamofire
import AVFoundation

var autoPlayAudioMute = true
protocol AutoPlayDelegate: AnyObject {
    func playerItemDidReachEnd()
}

class RecommendVC: UIViewController {
    
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
//    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true
    
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
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            if let videoCell = recommendCollection.cellForItem(at: visibleIP!) as? RecommendCVCell {
                let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
                if seekTime?.seconds ?? 0 > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
                videoCell.stopPlayback(isEnded: false)
                print("scrollToTop. stop play")
            }
            visibleIP = nil
        }
        
        recommendCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendCollection.refreshControl = recommendRC
        
        getDataFromJson()
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("RecommendVC viewDidDisappear")
        guard visibleIP != nil else { return }
        
        // 화면 이동 시 재생중지
        if let videoCell = recommendCollection.cellForItem(at: visibleIP!) as? RecommendCVCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
    
    var headerH: CGFloat!
    override func viewDidLayoutSubviews() {
        // 라벨 제외한 헤더 영역 사이즈 계산
        headerH = (233 + 10) / 414 * view.frame.width
        print("headerH : \(String(describing: headerH))")
    }
    
    //API
    var default1 = 0
    
    func getDataFromJson() {
        if let url = URL(string: makeStringKoreanEncoded(Recommend_Video_URL + "/모든?offset=\(default1)&limit=20")) {
            self.isLoading = true
            
            default1 += 20
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //print(json.body)
                    //                    self.recommendVideo = json
                    if self.default1 == 20 {
                        self.recommendVideo.body.removeAll()
                    }
                    self.recommendVideo.body.append(contentsOf: json.body)
                    /**
                     06.14
                     자동재생을 on 했을 때, 추천에 나타난 데이터를 활용하기 위해 싱글톤을 사용했습니다.
                     */
                }
                DispatchQueue.main.async {
                    self.recommendCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    func getDataFromJsonSecond() {
        if let url = URL(string: "\(apiBaseURL)/v/video/recommendvid?offset=\(default1)&limit=20") {
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
        default1 = 0
        getDataFromJson()
        sender.endRefreshing()
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
        
        cell.videoID = indexData.videoId
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoThumbnail.sizeToFit()
        cell.videoTitle.text = indexData.title
        cell.teachersName.text = (indexData.teacherName ?? "nil") + " 선생님"
        cell.subjects.text = indexData.subject
        cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor ?? "nil")
        cell.starRating.text = indexData.rating?.withDouble() ?? "0.0"
        cell.delegate = self
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
//            DispatchQueue.global().async {
//                sleep(2)
                
//                DispatchQueue.main.async {
//                    self.recommendCollection.reloadData()
//                    self.isLoading = false
//                }
//            }
            getDataFromJson()
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
    
    //0707 - edited by hp
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = view.frame.width
        return CGSize(width: width, height: (width / 16 * 9 + 70))
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
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == self.recommendVideo.body.count - 1 && !self.isLoading {
            loadMoreData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = recommendCollection.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = recommendCollection.cellForItem(at: ip) as? RecommendCVCell {
                cells.append(videoCell)
            }
        }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생 중지
        if scrollView.contentOffset.y == 0 {
            if let videoCell = cells[0] as? RecommendCVCell {
                if visibleIP != nil {
                    print("stopPlayback")
                    let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
                    if seekTime?.seconds ?? 0 > 0 {
                        seekTimes[videoCell.videoID] = seekTime
                    }
                    videoCell.stopPlayback(isEnded: false)
                    visibleIP = nil
                }
            }
            return
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 마지막 아이템까지 스크롤된 경우 마지막 아이템 재생
        // - 이전 재생 videoCell 이 65% 이상 가려지기 전에 다음 항목 재생되도록 별도 처리
        let heightSV = scrollView.frame.size.height
        let offSetY = scrollView.contentOffset.y
        let distanceFromBot = scrollView.contentSize.height - offSetY - (loadingView?.frame.height ?? 0)
        if distanceFromBot <= heightSV {// distanceFromBot == heightSV 인 순간 바닥점 터치.
            print("reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = recommendCollection.cellForItem(at: visibleIP!) as! RecommendCVCell
                print("stop current item")
                let seekTime = beforeVideoCell.avPlayer?.currentItem?.currentTime()
                if seekTime?.seconds ?? 0 > 0 {
                    seekTimes[beforeVideoCell.videoID] = seekTime
                }
                beforeVideoCell.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (recommendCollection.cellForItem(at: visibleIP!) as! RecommendCVCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            // 마지막 항목에 도달한 경우 loadingView 숨기기.
            if !(loadingView?.isHidden ?? true) {
                loadingView?.isHidden = true
            }
            return
        }
        
        if loadingView?.isHidden ?? true {
            loadingView?.isHidden = false
        }
        

        if cellCount >= 2 {
            // check last item
//            print("contentSize : \(scrollView.contentSize)")
            
            // 아이템 재생위치 계산
            if visibleIP == nil {
                if headerH < scrollView.contentOffset.y {
                    print("play first item")
                    let videoCell = cells[0] as! RecommendCVCell
                    visibleIP = indexPaths[0]
                    videoCell.startPlayback(seekTimes[videoCell.videoID])
                }
            } else {
                // item count change..
                let beforeVideoCell = recommendCollection.cellForItem(at: visibleIP!) as! RecommendCVCell
                let beforeCellVisibleH = beforeVideoCell.frame.intersection(recommendCollection.bounds).height
                
//                print("beforeCellVisibleH : \(beforeCellVisibleH/beforeVideoCell.frame.height * 100)")
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if beforeCellVisibleH < beforeVideoCell.frame.height * 0.65 {
                    print("stop current item")
                    let seekTime = beforeVideoCell.avPlayer?.currentItem?.currentTime()
                    if seekTime?.seconds ?? 0 > 0 {
                        seekTimes[beforeVideoCell.videoID] = seekTime
                    }
                    beforeVideoCell.stopPlayback(isEnded: false)
                    
                    var afterVideoCell: RecommendCVCell? = nil
                    if visibleIP!.row == indexPaths[0].row {
                        print("scroll to down")
                        visibleIP = indexPaths[1]
                        afterVideoCell = (recommendCollection.cellForItem(at: visibleIP!) as! RecommendCVCell)
                    } else if visibleIP!.row == indexPaths[cellCount - 1].row {
                        print("scroll to up")
                        visibleIP = indexPaths[cellCount - 2]
                        afterVideoCell = (recommendCollection.cellForItem(at: visibleIP!) as! RecommendCVCell)
                    } else {
                        print("visibleIP : \(visibleIP!.row)")
                        return
                    }
                    afterVideoCell!.startPlayback(seekTimes[afterVideoCell!.videoID])
                }
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forRowAt indexPath: IndexPath) {
//        print("end = \(indexPath)")
//        if let videoCell = cell as? RecommendCVCell {
//            videoCell.stopPlayback(isEnded: false)
//        }
//    }
}

extension RecommendVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 자동 재생 중지
        if visibleIP != nil {
            if let videoCell = recommendCollection.cellForItem(at: visibleIP!) as? RecommendCVCell {
                let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
                if seekTime?.seconds ?? 0 > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
                videoCell.stopPlayback(isEnded: false)
            }
            visibleIP = nil
        }
        
        // 토큰이 없는 경우
        // -> 추천 동영상 비디오 경로 API & 추천 동영상 비디오 노트 API를 호출한다.
        if Constant.isGuestKey {
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
        if let videoID = recommendVideo.body[selectedRow].videoId {
            videoDataManager.isFirstPlayVideo = true
            vc.delegate = self
            vc.id = videoID
            if let seekTime = seekTimes[videoID] {
                print("set seekTime \(seekTime.seconds)")
                vc.autoPlaySeekTime = seekTime
                vc.isStartVideo = true
//            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
            }
            
            vc.modalPresentationStyle = .overFullScreen
            
            autoPlayDataManager.currentViewTitleView = "추천"
            autoPlayDataManager.isAutoPlay = false
            autoPlayDataManager.videoDataList.removeAll()
            autoPlayDataManager.videoSeriesDataList.removeAll()
            autoPlayDataManager.currentIndex = -1
            
            self.present(vc, animated: true)
        }
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
        
        //0707 - edited by hp
        return CGSize(width: width, height: (width / 16 * 9 + 70))
    }
}


extension RecommendVC: RecommendCRVDelegate {
    func presentVideoControllerInBanner(videoID: String) {
        
        let vc = VideoController()
        let videoDataManager = VideoDataManager.shared
        videoDataManager.isFirstPlayVideo = true
        vc.delegate = self
        vc.id = videoID
        vc.modalPresentationStyle = .overFullScreen
//        vc.recommendReceiveData = recommendVideo
        
        autoPlayDataManager.currentViewTitleView = "추천"
        autoPlayDataManager.isAutoPlay = false
        autoPlayDataManager.videoDataList.removeAll()
        autoPlayDataManager.videoSeriesDataList.removeAll()
        autoPlayDataManager.currentIndex = -1
        
        self.present(vc, animated: true)
    }
}

extension RecommendVC: VideoControllerDelegate {
    
    func recommandVCPresentVideoVC() {
        let vc = VideoController()
        vc.modalPresentationStyle = .overFullScreen
        vc.id = "15188"
        self.present(vc, animated: false)
    }
}

extension RecommendVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = recommendCollection.cellForItem(at: visibleIP!) as? RecommendCVCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.recommendVideo.body.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            recommendCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}
