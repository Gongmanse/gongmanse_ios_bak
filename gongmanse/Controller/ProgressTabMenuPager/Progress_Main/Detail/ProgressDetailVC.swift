//
//  ProgressDetailVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/09.
//

import UIKit
import AVFoundation

class ProgressDetailVC: UIViewController {
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    //MARK: - Properties
    
    // 자동재생기능 구현을 위한 싱글톤객체를 생성한다.
    let autoPlayDataManager = AutoplayDataManager.shared
    
    @IBOutlet weak var lessonTitle: UILabel!                // 어떤 강의인지 viewModel을 통해 전달받아야함.
    @IBOutlet weak var numberOfLesson: UILabel!             // 몇 개의 강의가 있는지 viewModel을 통해 전달받아야함. 
    @IBOutlet weak var collectionView: UICollectionView!    
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var autoPlayLabel: UILabel!
    
    @IBOutlet weak var subjectColor: UIStackView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("ProgressDetailVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    private var progressBodyData: [ProgressDetailBody]?
    private var progressHeaderData: ProgressDetailHeader?
    private let detailCellIdentifier = "ProgressDetailCell"
    
    // 무한 스크롤
    var cellCount: Int = 0
    var isListMore: Bool = true
    
    var progressIdentifier = ""                             // 서버와 통신할 progressID
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // UISwitch 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        autoPlaySwitch.addTarget(self, action: #selector(playSwitchValueChanged(_:)), for: .valueChanged)
        autoPlayLabel.textColor = .black
        
        navigationItem.title = "진도 학습"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(handleBackBtn))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(UINib(nibName: detailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: detailCellIdentifier)
        
        progressDataManager(progressID: progressIdentifier, limit: 20, offset: 0)
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        print("ProgressDetailVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
    }
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? ProgressDetailCell
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! ProgressDetailCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("ProgressDetailVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = collectionView.cellForItem(at: visibleIP!) as? ProgressDetailCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    
    /// 자동재생 설정 여부를 확인하기 위한 콜백메소드
    @objc func playSwitchValueChanged(_ sender: UISwitch) {
        autoPlayLabel.textColor = sender.isOn ? .black : .lightGray
    }
    
    func progressDataManager(progressID: String, limit: Int, offset: Int) {
        
        let requestDetailData = ProgressDetailListAPI(progressId: progressID, limit: limit, offset: offset)
        requestDetailData.requestDetailList { [weak self] result in
            if offset == 0 {
                self?.progressBodyData = result.body
                self?.progressHeaderData = result.header
                DispatchQueue.main.async {
                    // 상단 오른쪽 스택뷰
                    self?.stackConfiguration()
                    self?.collectionView.reloadData()
                }
            }else {
                
                if result.body?.count == 0 {
                    self?.isListMore = false
                }
                
                self?.progressBodyData?.append(contentsOf: result.body!)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    //MARK: - Actions
    
    @objc func handleBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper functions
    
    func stackConfiguration() {
        
        
        let headerData = progressHeaderData?.label
        
        if headerData?.grade == "초등" {
            gradeLabel.text = "초"
        }else if headerData?.grade == "중등" {
            gradeLabel.text = "중"
        }else if headerData?.grade == "고등" {
            gradeLabel.text = "고"
        }
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white
        subjectLabel.text = headerData?.subject
        
        // gradeLabel
        gradeLabel.textColor = UIColor(hex: headerData?.subjectColor ?? "")
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 8
        
        
        // subjectColor
        subjectColor.backgroundColor = UIColor(hex: headerData?.subjectColor ?? "")
        subjectColor.layer.cornerRadius = subjectColor.frame.size.height / 2
        subjectColor.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        subjectColor.isLayoutMarginsRelativeArrangement = true
        
        configurelabel(rows: progressHeaderData?.totalRows ?? "", title: headerData?.title ?? "")
    }
    
    func configurelabel(rows: String, title: String) {
        
        // 제목 타이틀 텍스트
        lessonTitle.text = title
        lessonTitle.font = .appBoldFontWith(size: 17)
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: "\(rows)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfLesson.attributedText = attributedString
    }
}




//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ProgressDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progressBodyData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailCellIdentifier, for: indexPath) as? ProgressDetailCell else { return UICollectionViewCell() }
        
        let progressIndexPath = progressBodyData?[indexPath.row]
        
        cell.subjectSecond.isHidden = progressIndexPath?.unit != nil ? false : true
        cell.delegate = self
        cell.videoID = progressIndexPath?.videoId
        cell.lessonImage.setImageUrl(progressIndexPath?.thumbnail ?? "")
        cell.lessonTitle.text = progressIndexPath?.title
        cell.subjectFirst.text = progressIndexPath?.subject
        cell.subjectSecond.text = progressIndexPath?.unit
        cell.starRating.text = progressIndexPath?.rating?.withDouble() ?? "0.0"
        cell.teathername.text = progressIndexPath?.teacherChangeName
        cell.subjectFirst.backgroundColor = UIColor(hex: progressIndexPath?.subjectColor ?? "")
        cell.subjectSecond.backgroundColor = .mainOrange
        
        let totalRows = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row == totalRows - 1 && isListMore == true {
            cellCount += 20
            progressDataManager(progressID: progressIdentifier, limit: 20, offset: cellCount)
        }
        return cell
    }
    
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
            // 비디오 연결
            let vc = VideoController()
            let videoDataManager = VideoDataManager.shared
            if let receviedVideoID = self.progressBodyData?[indexPath.row].videoId {
                videoDataManager.isFirstPlayVideo = true
                vc.id = receviedVideoID
                if let seekTime = seekTimes[receviedVideoID] {
                    print("set seekTime \(seekTime.seconds)")
                    vc.autoPlaySeekTime = seekTime
                    vc.isStartVideo = true
    //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
                }
                
                vc.modalPresentationStyle = .overFullScreen
                
                autoPlayDataManager.currentViewTitleView = "진도학습"
                autoPlayDataManager.isAutoPlay = self.autoPlaySwitch.isOn
                autoPlayDataManager.currentJindoId = (self.progressBodyData?[indexPath.row].progressId)!
                autoPlayDataManager.videoDataList.removeAll()
    //            progressBodyData -> VideoModels
    //            autoPlayDataManager.videoDataList.append(contentsOf: progressBodyData)
                autoPlayDataManager.videoSeriesDataList.removeAll()
                autoPlayDataManager.currentIndex = self.autoPlaySwitch.isOn ? indexPath.row : -1
                            
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isGuest {
            print("isGuest")
            return
        }
        
        let indexPaths = collectionView.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = collectionView.cellForItem(at: ip) as? ProgressDetailCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("ProgressDetailVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
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
            print("ProgressDetailVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? ProgressDetailCell
                print("ProgressDetailVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! ProgressDetailCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
//            print("cellCount : \(cellCount)")
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("ProgressDetailVC play first item")
                let videoCell = cells[0] as! ProgressDetailCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? ProgressDetailCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(collectionView.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("ProgressDetailVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    print("ProgressDetailVC visibleIP!.row : \(visibleIP!.row)")
                    // 현재 화면에 보여지고있는 셀들 중에서 다음 재생할 파일 선택.
                    // 빠르게 스크롤 시 재생중이던 셀과 다음 재생하려고 하는 셀이 화면에 안보이는 상태일 수 있어 내용 수정.
                    var indexPath = IndexPath(row: indexPaths[1].row, section: 0)// 중간 데이터로 초기화
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        print("ProgressDetailVC move up")
                        for ip in indexPaths {
//                            print("ProgressDetailVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 위 셀을 선택
                                var row = visibleIP!.row - 1
                                if row < 0 { row = 0 }
                                indexPath.row = row
                            }
                        }

                    }
                    else if (self.lastContentOffset < scrollView.contentOffset.y) {
                        print("ProgressDetailVC move down")
                        for ip in indexPaths {
//                            print("ProgressDetailVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 아래 셀을 선택
                                var row = visibleIP!.row + 1
                                if row == self.progressBodyData!.count { row = self.progressBodyData!.count - 1 }
                                indexPath.row = row
                            }
                        }
                    } else {
                        print("???")
                    }
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    visibleIP = indexPath
                    let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! ProgressDetailCell)
                    afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? ProgressDetailCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let _ = progressBodyData?.count  else { return }
        
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
    }
}


//MARK: - UICollectionViewFlowLayout

extension ProgressDetailVC: UICollectionViewDelegateFlowLayout {
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: (width / 16 * 9 + 80))
    }
    
}

extension ProgressDetailVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = collectionView.cellForItem(at: visibleIP!) as? ProgressDetailCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < self.progressBodyData!.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}
