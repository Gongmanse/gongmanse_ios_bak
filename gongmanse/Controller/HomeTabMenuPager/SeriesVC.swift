import UIKit
import AVFoundation

class SeriesVC: UIViewController {
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    @IBOutlet weak var mainHeaderView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainTeacherName: UILabel!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var videoCount: UILabel!
    
    @IBOutlet weak var subjectColor: UIStackView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("SeriesVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        seriesCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    var seriesShow: SeriesModels?
    var receiveSeriesId: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromJson()
        mainFontAndRadiusSettings()
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        print("SeriesVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
        

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let currY = self.seriesCollectionView.contentOffset.y
//            print("SeriesVC offsetY : \(currY)")
//            if currY == 0 {
//                self.seriesCollectionView.setContentOffset(CGPoint(x: 0, y: currY + 1), animated: false)
//            } else {
//                self.seriesCollectionView.setContentOffset(CGPoint(x: 0, y: currY - 1), animated: false)
//            }
//        }
    }
    
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = seriesCollectionView.cellForItem(at: visibleIP!) as? SeriesCollectionViewCell
                
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (seriesCollectionView.cellForItem(at: visibleIP!) as! SeriesCollectionViewCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("SeriesVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = seriesCollectionView.cellForItem(at: visibleIP!) as? SeriesCollectionViewCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    func mainFontAndRadiusSettings() {
        mainTeacherName.font = UIFont.appEBFontWith(size: 13)
    
    }
    
    func getDataFromJson() {
        if let url = URL(string: "\(apiBaseURL)/v/video/serieslist?series_id=\(receiveSeriesId ?? "")&offset=0&limit=60") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(SeriesModels.self, from: data) {
                    //print(json.body)
                    self.seriesShow = json
                }
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadData()
                    self.textSettings()
                    self.mainSettings()
                }

            }.resume()
        }
    }
    
    @IBAction func goToBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textSettings() {
        guard let value = self.seriesShow else { return }
        
        self.videoCount.text = "총 \(value.totalNum)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])

        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoCount.text! as NSString).range(of: value.totalNum))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoCount.text! as NSString).range(of: value.totalNum))

        self.videoCount.attributedText = attributedString
    }
    
    func mainSettings() {
        
        guard let teacherNames = seriesShow?.seriesInfo.sTeacher else { return }

        
        mainTitle.text = seriesShow?.seriesInfo.sTitle
        mainTeacherName.text = teacherNames + " 선생님"
        
        let headerData = seriesShow?.seriesInfo
        
        if headerData?.sGrade == "초등" {
            gradeLabel.text = "초"
        }else if headerData?.sGrade == "중등" {
            gradeLabel.text = "중"
        }else if headerData?.sGrade == "고등" {
            gradeLabel.text = "고"
        }
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white
        subjectLabel.text = headerData?.sSubject
        
        // gradeLabel
        gradeLabel.textColor = UIColor(hex: headerData?.sSubjectColor ?? "")
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 8
        
        
        // subjectColor
        subjectColor.backgroundColor = UIColor(hex: headerData?.sSubjectColor ?? "")
        subjectColor.layer.cornerRadius = subjectColor.frame.size.height / 2
        subjectColor.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        subjectColor.isLayoutMarginsRelativeArrangement = true
    }
}

extension SeriesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.seriesShow?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCollectionViewCell", for: indexPath) as? SeriesCollectionViewCell else { return UICollectionViewCell() }
        
        guard let json = self.seriesShow else { return cell }
        
        let indexData = json.data[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(fileBaseURL + "/" + indexData.sThumbnail))
        cell.delegate = self
        cell.videoID = indexData.id
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)
        cell.teachersName.text = indexData.sTeacher + " 선생님"
        
        if indexData.sUnit == "" {
            cell.term.isHidden = true
        } else if indexData.sUnit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData.sUnit == "2" {
            cell.term.isHidden = false
            cell.term.text = "ii"
        } else {
            cell.term.isHidden = false
            cell.term.text = indexData.sUnit
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 자동 재생 중지
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        AutoplayDataManager.shared.isAutoPlay = false
        AutoplayDataManager.shared.currentIndex = -1
        AutoplayDataManager.shared.videoDataList.removeAll()
        AutoplayDataManager.shared.videoSeriesDataList.removeAll()
        
        let vc = VideoController()
        if let videoID = seriesShow?.data[indexPath.row].id {
            vc.id = videoID
            if let seekTime = seekTimes[videoID] {
                print("set seekTime \(seekTime.seconds)")
                vc.autoPlaySeekTime = seekTime
                vc.isStartVideo = true
    //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
            }
            vc.modalPresentationStyle = .overFullScreen
            
            present(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isGuest {
            print("isGuest")
            return
        }
        
        let indexPaths = seriesCollectionView.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = seriesCollectionView.cellForItem(at: ip) as? SeriesCollectionViewCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("SeriesVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
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
            print("SeriesVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = seriesCollectionView.cellForItem(at: visibleIP!) as? SeriesCollectionViewCell
                print("SeriesVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (seriesCollectionView.cellForItem(at: visibleIP!) as! SeriesCollectionViewCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("SeriesVC play first item")
                let videoCell = cells[0] as! SeriesCollectionViewCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = seriesCollectionView.cellForItem(at: visibleIP!) as? SeriesCollectionViewCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(seriesCollectionView.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("SeriesVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    print("SeriesVC visibleIP!.row : \(visibleIP!.row)")
                    // 현재 화면에 보여지고있는 셀들 중에서 다음 재생할 파일 선택.
                    // 빠르게 스크롤 시 재생중이던 셀과 다음 재생하려고 하는 셀이 화면에 안보이는 상태일 수 있어 내용 수정.
                    var indexPath = IndexPath(row: indexPaths[1].row, section: 0)// 중간 데이터로 초기화
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        print("SeriesVC move up")
                        for ip in indexPaths {
//                            print("SeriesVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 위 셀을 선택
                                var row = visibleIP!.row - 1
                                if row < 0 { row = 0 }
                                indexPath.row = row
                            }
                        }

                    }
                    else if (self.lastContentOffset < scrollView.contentOffset.y) {
                        print("SeriesVC move down")
                        for ip in indexPaths {
//                            print("SeriesVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 아래 셀을 선택
                                var row = visibleIP!.row + 1
                                if row == self.seriesShow!.data.count { row = self.seriesShow!.data.count - 1 }
                                indexPath.row = row
                            }
                        }
                    } else {
                        print("???")
                    }
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    visibleIP = indexPath
                    let afterVideoCell = (seriesCollectionView.cellForItem(at: visibleIP!) as! SeriesCollectionViewCell)
                    afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? SeriesCollectionViewCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
}

extension SeriesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: (width / 16 * 9 + 70))
    }
}

extension SeriesVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = seriesCollectionView.cellForItem(at: visibleIP!) as? SeriesCollectionViewCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.seriesShow!.data.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            seriesCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}
