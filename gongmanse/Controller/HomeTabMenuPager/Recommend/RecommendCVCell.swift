import UIKit
import AVFoundation

class RecommendCVCell: UICollectionViewCell {
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var starRating: UILabel!
    
    @IBOutlet weak var videoAreaView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    var requestDelayTimer: Timer? //동영상 정보 요청 딜레이 체크
    var videoID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
        
        self.setupMoviePlayer()
    }
    
    // MARK: - video player setting
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupMoviePlayer() {
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none

        // You need to have different variations
        // according to the device so as the avplayer fits well
        if UIScreen.main.bounds.width == 375 {
            let widthRequired = self.frame.size.width - 20
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        } else if UIScreen.main.bounds.width == 320 {
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
        } else {
            let widthRequired = self.frame.size.width
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }
        
        self.backgroundColor = .clear
        self.videoAreaView.layer.insertSublayer(avPlayerLayer!, at: 0)

        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }

    func stopPlayback(){
        if videoAreaView.isHidden { return }
        
        print("=================stopPlayback=============\(String(describing: videoID))")
        // stop video & hide video area
//        self.avPlayer?.pause()
        videoAreaView.isHidden = true
    }

    func startPlayback(){
        if !videoAreaView.isHidden { return }
        
        print("=================startPlayback=============\(String(describing: videoID))")
        // show progress & request video url

        requestDelayTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.waitDelay), userInfo: nil, repeats: false)
    }

    @objc func waitDelay() {
        videoAreaView.isHidden = false
        loadingView.isHidden = false
        requestVideoUrl()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("")
//        let p: AVPlayerItem = notification.object as! AVPlayerItem
//        p.seek(to: CMTime.zero)
    }
    
    //MARK: -  request video info
    func requestVideoUrl() {
        guard let _ = videoID else { return }
        
        if Reachability.isConnectedToNetwork() {
            if Constant.isGuestKey || Constant.remainPremiumDateInt == nil {
                GuestKeyDataManager().GuestKeyAPIGetData(videoID) { response in
                    if self.videoTitle.isEqual(response.data.sTitle) {
                        self.sestVideoItem(url: URL(string: response.data.source_url)!)
                    }
                }
            } else {
                DetailVideoDataManager().DetailVideoDataManager(videoID) { response in
                    if self.videoTitle.isEqual(response.data.sTitle) {
                        self.sestVideoItem(url: URL(string: response.data.source_url!)!)
                    }
                }
            }
        }
    }
    func sestVideoItem(url: URL) {
        loadingView.isHidden = true
        videoPlayerItem = AVPlayerItem(url: url)
    }
}
