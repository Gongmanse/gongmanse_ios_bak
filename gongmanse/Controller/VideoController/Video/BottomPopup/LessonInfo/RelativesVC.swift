import UIKit

class RelativesVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerSubject: UILabel!
    @IBOutlet weak var headerTeachersName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalCount: UILabel!
    
    var pipVC: PIPController?
    var pipData: PIPVideoData? {
        didSet {
            configurePIPView(pipData: pipData)
        }
    }
    
    var relatives: SeriesModels?
    var receiveVideoID: String? = ""
    
    private let pipContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    private let xButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(xButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private var isPlayPIPVideo: Bool = false
    private let pipPlayPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(playPauseButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let lessonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 13)
        label.textColor = .black
        return label
    }()
    
    private let teachernameLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 11)
        label.textColor = .gray
        return label
    }()
    
    @objc func xButtonDidTap() {
        
        if let pipVC = self.pipVC {
            pipVC.player?.pause()
        }
        
        UIView.animate(withDuration: 0.33) {
            self.pipContainerView.alpha = 0
        }
    }
    
    @objc func playPauseButtonDidTap() {
        isPlayPIPVideo = !isPlayPIPVideo
        
        if isPlayPIPVideo {
            pipVC?.player?.pause()
            pipPlayPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            pipVC?.player?.play()
            pipPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromJson()
        fontAndRadiusSettings()
    }
    
    func fontAndRadiusSettings() {
        self.headerSubject.layer.cornerRadius = 13
        self.headerSubject.clipsToBounds = true
        self.headerSubject.textColor = .white
        
        self.headerTitle.font = UIFont.appBoldFontWith(size: 19)
        self.headerSubject.font = UIFont.appBoldFontWith(size: 17)
        self.headerTeachersName.font = UIFont.appEBFontWith(size: 13)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/video/relatives?video_id=\(receiveVideoID ?? "nil")") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(SeriesModels.self, from: data) {
                    //print(json.body)
                    self.relatives = json
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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
        guard let value = self.relatives else { return }
        
        self.totalCount.text = "총 \(value.totalNum)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: totalCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (totalCount.text! as NSString).range(of: value.totalNum))
        attributedString.addAttribute(.foregroundColor, value: UIColor.mainOrange, range: (totalCount.text! as NSString).range(of: value.totalNum))
        
        self.totalCount.attributedText = attributedString
    }
    
    func mainSettings() {
        guard let teacherNames = relatives?.seriesInfo.sTeacher else { return }
        guard let subjectColor = relatives?.seriesInfo.sSubjectColor else { return }
        
        headerTitle.text = relatives?.seriesInfo.sTitle
        headerSubject.text = relatives?.seriesInfo.sSubject
        headerTeachersName.text = teacherNames + " 선생님"
        headerSubject.backgroundColor = UIColor(hex: subjectColor)
    }
    
    func configurePIPView(pipData: PIPVideoData?) {
        
        let pipDataManager = PIPDataManager.shared
        
        let videoDataManager = VideoDataManager.shared
        
        let pipData = PIPVideoData(isPlayPIP: true,
                                   videoURL: videoDataManager.previousVideoURL,
                                   currentVideoTime: pipDataManager.currentVideoTime ?? Float(),
                                   videoTitle: videoDataManager.previousVideoTitle ?? "",
                                   teacherName: videoDataManager.previousVideoTeachername ?? "")
        
        let pipHeight = view.frame.height * 0.085
        self.pipVC = PIPController(isPlayPIP: true)
        guard let pipVC = self.pipVC else { return }
        pipVC.pipVideoData = pipData
        
        /* pipContainerView - Constraint */
        view.addSubview(pipContainerView)
        pipContainerView.anchor(left: view.leftAnchor,
                                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                height: pipHeight)
        
        let pipTapGesture = UITapGestureRecognizer(target: self, action: #selector(pipViewDidTap))
        pipContainerView.addGestureRecognizer(pipTapGesture)
        pipContainerView.isUserInteractionEnabled = true
        
        /* pipVC.view - Constraint  */
        pipContainerView.addSubview(pipVC.view)
        pipVC.view.anchor(top:pipContainerView.topAnchor)
        pipVC.view.centerY(inView: pipContainerView)
        pipVC.view.setDimensions(height: pipHeight,
                                 width: pipHeight * 1.77)
        
        /* xButton - Constraint */
        pipContainerView.addSubview(xButton)
        xButton.setDimensions(height: 25,
                              width: 25)
        xButton.centerY(inView: pipContainerView)
        xButton.anchor(right: pipContainerView.rightAnchor,
                       paddingRight: 5)
        
        /* pipPlayPauseButton - Constraint*/
        pipContainerView.addSubview(pipPlayPauseButton)
        pipPlayPauseButton.setDimensions(height: 25,
                                         width: 25)
        pipPlayPauseButton.centerY(inView: xButton)
        pipPlayPauseButton.anchor(right: xButton.leftAnchor,
                                  paddingRight: 10)
        
        /* lessonTitleLabel - Constraint */
        pipContainerView.addSubview(lessonTitleLabel)
        lessonTitleLabel.anchor(top: pipContainerView.topAnchor,
                                left: pipContainerView.leftAnchor,
                                paddingTop: 13,
                                paddingLeft: pipHeight * 1.77 + 5,
                                height: 17)
        lessonTitleLabel.text = pipData.videoTitle
        
        /* teachernameLabel - Constraint */
        pipContainerView.addSubview(teachernameLabel)
        teachernameLabel.anchor(top: lessonTitleLabel.bottomAnchor,
                                left: lessonTitleLabel.leftAnchor,
                                paddingTop: 5,
                                height: 15)
        teachernameLabel.text = pipData.teacherName + " 선생님"
    }
    
    @objc func pipViewDidTap(_ sender: UITapGestureRecognizer) {
        
        setRemoveNotification()
        dismissRelativesVCOnPlayingPIP()
    }
    
    func setRemoveNotification() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func dismissRelativesVCOnPlayingPIP() {
        
        let pipDataManager = PIPDataManager.shared
        guard let pipVC = self.pipVC else { return }
        
        pipVC.player?.pause()
        setRemoveNotification()
        
        pipDataManager.currentVideoCMTime = pipVC.currentVideoTime
        dismiss(animated: false)
    }
}

extension RelativesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.relatives?.data else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelativesCollectionViewCell", for: indexPath) as? RelativesCollectionViewCell else { return UICollectionViewCell() }
        
        guard let json = self.relatives else { return cell }
        
        let indexData = json.data[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(fileBaseURL + "/" + indexData.sThumbnail))
        
        cell.thumbnailImage.contentMode = .scaleAspectFill
        cell.thumbnailImage.sd_setImage(with: url)
        cell.title.text = indexData.sTitle
        cell.subject.text = indexData.sSubject
        cell.subject.backgroundColor = UIColor(hex: indexData.sSubjectColor)
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
        
        let vc = VideoController()
        vc.modalPresentationStyle = .fullScreen
        let videoID = relatives?.data[indexPath.row].id
        vc.id = videoID
        present(vc, animated: true)
    }
}

extension RelativesVC: UICollectionViewDelegateFlowLayout {
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
