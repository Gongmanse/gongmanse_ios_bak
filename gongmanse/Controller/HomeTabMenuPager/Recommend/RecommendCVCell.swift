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
    private var seekTime: CMTime?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        videoAreaView.layer.cornerRadius = 13
        
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
        requestDelayTimer?.invalidate()
    }
    
    func setupMoviePlayer() {
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none

        avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.videoAreaView.frame.size.width, height: self.videoAreaView.frame.size.height)
        avPlayerLayer?.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
        avPlayerLayer?.cornerRadius = 13

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
        requestDelayTimer?.invalidate()
        avPlayer?.pause()
        
        videoAreaView.isHidden = true
        loadingView.isHidden = true
        loadingView.stopAnimating()
    }
    
    func startPlayback(_ seekTime: CMTime?){
        if !videoAreaView.isHidden { return }
        
        print("=================startPlayback=============\(String(describing: videoID))")
        // show progress & request video url
        self.seekTime = seekTime
        
        videoAreaView.isHidden = false
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
//        }
        
        requestDelayTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.waitDelay), userInfo: nil, repeats: false)
    }

    @objc func waitDelay() {
        requestVideoUrl()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("playerItemDidReachEnd")
//        let p: AVPlayerItem = notification.object as! AVPlayerItem
//        p.seek(to: CMTime.zero)
    }
    
    //MARK: -  request video info
    func requestVideoUrl() {
        guard let _ = videoID else { return }
        
        if Reachability.isConnectedToNetwork() {
            if Constant.isGuestKey || Constant.remainPremiumDateInt == nil {
                GuestKeyDataManager().GuestKeyAPIGetData(videoID) { response in
                    print("current cell : \(String(describing: self.videoTitle.text))")
                    print("response data : \(response.data.sTitle)")
                    if (self.videoTitle.text ?? "").isEqual(response.data.sTitle) {
                        self.setVideoItem(url: URL(string: response.data.source_url)!)
                    }
                }
            } else {
                DetailVideoDataManager().DetailVideoDataManager(videoID) { response in
                    print("current cell : \(String(describing: self.videoTitle.text))")
                    print("response data : \(response.data.sTitle)")
                    if (self.videoTitle.text ?? "").isEqual(response.data.sTitle) {
                        
                        self.setVideoItem(url: URL(string: response.data.source_url!)!)
                    }
                }
            }
        }
    }
    
    func setVideoItem(url: URL) {
        print("setVideoItem")
        loadingView.isHidden = true
        loadingView.stopAnimating()
        videoPlayerItem = AVPlayerItem(url: url)
        avPlayer?.play()
        
        if let seekTime = seekTime {
            print("seek to \(seekTime.seconds)")
            avPlayer?.seek(to: seekTime)
        }
    }
}
