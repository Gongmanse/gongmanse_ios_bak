import UIKit
import AVFoundation

class PopularVC: UIViewController {
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    var pageIndex: Int!
    
    var popularVideo = VideoInput(header: HeaderData.init(resultMsg: "", totalRows: "", isMore: ""), body: [VideoModels]())
    
    var popularVideoSecond: BeforeApiModels?
    
    let popularRC: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var popularCollection: UICollectionView!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("PopularVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        popularCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    // 무한 스크롤 프로퍼티
    var gradeText: String = ""
    var listCount: Int = 0
    var isDataListMore: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Constant.token != "" {
            getDataFromJsonSecond(grade: gradeText, offset: listCount)
        } else {
            getDataFromJsonSecond(grade: "", offset: listCount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popularCollection.refreshControl = popularRC
        
        viewTitleSettings()
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        print("PopularVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
        Constant.delegate = self

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let currY = self.popularCollection.contentOffset.y
//            print("PopularVC offsetY : \(currY)")
//            if currY == 0 {
//                self.popularCollection.setContentOffset(CGPoint(x: 0, y: currY + 1), animated: false)
//            } else {
//                self.popularCollection.setContentOffset(CGPoint(x: 0, y: currY - 1), animated: false)
//            }
//        }
    }
    
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = popularCollection.cellForItem(at: visibleIP!) as? PopularCVCell
                
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (popularCollection.cellForItem(at: visibleIP!) as! PopularCVCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("PopularVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = popularCollection.cellForItem(at: visibleIP!) as? PopularCVCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    func viewTitleSettings() {
        viewTitle.text = "인기HOT! 동영상 강의"
        
        let attributedString = NSMutableAttributedString(string: viewTitle.text!, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .medium), range: (viewTitle.text! as NSString).range(of: "HOT!"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: (viewTitle.text! as NSString).range(of: "HOT!"))
        
        self.viewTitle.attributedText = attributedString
    }
    
    func getDataFromJson() {
        if let url = URL(string: makeStringKoreanEncoded(Popular_Video_URL + "/모든?offset=0&limit=30")) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //print(json.body)
                    self.popularVideo.body.append(contentsOf: json.body)
                }
                DispatchQueue.main.async {
                    self.popularCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    /// 1.0 인기리스트 API
    func getDataFromJsonSecond(grade: String, offset: Int) {
        guard let gradeEncoding = grade.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        if let url = URL(string: "\(apiBaseURL)/v/video/trendingvid?offset=\(offset)&limit=20&grade=\(gradeEncoding)") {
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            switch isDataListMore {
            
            case false:
                return
                
            case true:
                if offset == 0 {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(BeforeApiModels.self, from: data) {
                            self.popularVideoSecond = json
                        }
                        DispatchQueue.main.async {
                            self.popularCollection.reloadData()
                        }
                        
                    }.resume()
                } else {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(BeforeApiModels.self, from: data) {
                            
                            if json.data.count == 0 {
                                self.isDataListMore = true
                                return
                            }
                            
                            for i in 0..<json.data.count {
                                self.popularVideoSecond?.data.append(json.data[i])
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.popularCollection.reloadData()
                        }
                        
                    }.resume()
                }
            }
            
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        popularCollection.reloadData()
        sender.endRefreshing()
    }
}

extension PopularVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //guard let data = self.popularVideo?.data else { return 0}
        //        let popularData = self.popularVideo
        //        return popularData.body.count
        return popularVideoSecond?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCVCell", for: indexPath) as! PopularCVCell
        //guard let json = self.popularVideo else { return cell }
        
        // 2.0 API
        //        let json = self.popularVideo
        //        let indexData = json.body[indexPath.row]
        
        // 1.0 API
        if let indexData = popularVideoSecond?.data[indexPath.row] {
            let url = URL(string: makeStringKoreanEncoded("\(fileBaseURL)/\(indexData.sThumbnail)"))
        
        cell.videoID = indexData.id
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
            cell.teachersName.text = indexData.sTeacher + " 선생님"
        cell.subjects.text = indexData.sSubject
            cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor )
        cell.delegate = self
        switch indexData.iRating {
        case "5":
            cell.starRating.text = "5.0"
        case "4":
            cell.starRating.text = "4.0"
        case "3":
            cell.starRating.text = "3.0"
        case "2":
            cell.starRating.text = "2.0"
        case "1":
            cell.starRating.text = "1.0"
        case "0":
            cell.starRating.text = "0.0"
        default:
            cell.starRating.text = indexData.iRating
        }
        
        if indexData.sUnit != "" {
            cell.term.isHidden = false
            cell.term.text = indexData.sUnit
        } else if indexData.sUnit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData.sUnit == "2" {
            cell.term.isHidden = false
            cell.term.text = "ii"
        } else {
            cell.term.isHidden = true
        }
        
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PopularTitleCVCell", for: indexPath) as? PopularTitleCVCell else {
                return UICollectionReusableView()
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isGuest {
            print("isGuest")
            return
        }
        
        let indexPaths = popularCollection.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = popularCollection.cellForItem(at: ip) as? PopularCVCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("PopularVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
            if isAutoScroll {
                // auto scroll 시 재생되지 않도록 적용
                isAutoScroll = false
            } else {
                startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
            }
            
//                let delay = isAutoScroll ? 0.3 : 0.0
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    // auto scroll 시 화면 그려진 이후에 재생되도록 딜레이 설정
//                    self.startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
//                    self.isAutoScroll = false
//                }
            return
        }

        // 마지막 아이템까지 스크롤된 경우 마지막 아이템 재생
        // - 이전 재생 videoCell 이 65% 이상 가려지기 전에 다음 항목 재생되도록 별도 처리
        let heightSV = scrollView.frame.size.height
        let offSetY = scrollView.contentOffset.y
        let distanceFromBot = scrollView.contentSize.height - offSetY
        if distanceFromBot <= heightSV {// distanceFromBot == heightSV 인 순간 바닥점 터치.
            print("PopularVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = popularCollection.cellForItem(at: visibleIP!) as? PopularCVCell
                print("PopularVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (popularCollection.cellForItem(at: visibleIP!) as! PopularCVCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("PopularVC play first item")
                let videoCell = cells[0] as! PopularCVCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = popularCollection.cellForItem(at: visibleIP!) as? PopularCVCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(popularCollection.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("PopularVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    print("PopularVC visibleIP!.row : \(visibleIP!.row)")
                    // 현재 화면에 보여지고있는 셀들 중에서 다음 재생할 파일 선택.
                    // 빠르게 스크롤 시 재생중이던 셀과 다음 재생하려고 하는 셀이 화면에 안보이는 상태일 수 있어 내용 수정.
                    var indexPath = IndexPath(row: indexPaths[1].row, section: 0)// 중간 데이터로 초기화
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        print("PopularVC move up")
                        for ip in indexPaths {
//                            print("PopularVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 위 셀을 선택
                                var row = visibleIP!.row - 1
                                if row < 0 { row = 0 }
                                indexPath.row = row
                            }
                        }

                    }
                    else if (self.lastContentOffset < scrollView.contentOffset.y) {
                        print("PopularVC move down")
                        for ip in indexPaths {
//                            print("PopularVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 아래 셀을 선택
                                var row = visibleIP!.row + 1
                                if row == self.popularVideoSecond!.data.count { row = self.popularVideoSecond!.data.count - 1 }
                                indexPath.row = row
                            }
                        }
                    } else {
                        print("???")
                    }
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    visibleIP = indexPath
                    let afterVideoCell = (popularCollection.cellForItem(at: visibleIP!) as! PopularCVCell)
                    afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? PopularCVCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
}

extension PopularVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 자동 재생 중지
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            let vc = VideoController()
            let videoDataManager = VideoDataManager.shared
            if let videoID = popularVideoSecond?.data[indexPath.row].id {
                videoDataManager.isFirstPlayVideo = true
                vc.id = videoID
                if let seekTime = seekTimes[videoID] {
                    print("set seekTime \(seekTime.seconds)")
                    vc.autoPlaySeekTime = seekTime
                    vc.isStartVideo = true
    //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
                }
                
                vc.modalPresentationStyle = .overFullScreen
                
                let autoDataManager = AutoplayDataManager.shared
                autoDataManager.currentViewTitleView = "인기"
                autoDataManager.isAutoPlay = false
                autoDataManager.videoDataList.removeAll()
                autoDataManager.videoSeriesDataList.removeAll()
                autoDataManager.currentIndex = -1
                
                present(vc, animated: true)
            }
        }
        
//        if Constant.remainPremiumDateInt != nil {
//            let vc = VideoController()
//            let videoDataManager = VideoDataManager.shared
//            videoDataManager.isFirstPlayVideo = true
//            vc.modalPresentationStyle = .fullScreen
//            let videoID = popularVideoSecond?.data[indexPath.row].id
//            vc.id = videoID
//            //            let seriesID = popularVideoSecond?.data[indexPath.row].iSeriesId
//            //            vc.popularSeriesId = seriesID
//            vc.popularReceiveData = popularVideo
//            vc.popularViewTitle = viewTitle.text
//
//            let autoDataManager = AutoplayDataManager.shared
//            autoDataManager.currentViewTitleView = "인기"
//
//            present(vc, animated: true)
//        } else if Constant.remainPremiumDateInt == nil {
//            presentAlert(message: "이용권을 구매해주세요")
//        }
//
//        else {
//            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = popularVideoSecond?.data.count  else { return }
        
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == cellCount - 1 {
            
            listCount += 20
            print(listCount)
            getDataFromJsonSecond(grade: gradeText, offset: listCount)
            
        }
    }
    
}

extension PopularVC: UICollectionViewDelegateFlowLayout {
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

extension PopularVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = popularCollection.cellForItem(at: visibleIP!) as? PopularCVCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.popularVideoSecond!.data.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            popularCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}

extension PopularVC: LoginStatusChecker {
    func logout() {
        isGuest = true
        print("PopularVC logout... current visibleIP : \(String(describing: visibleIP))")
        if let _ = visibleIP {
            stopCurrentVideoCell()
        }
    }
}
