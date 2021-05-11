/*
"DetailScreenController는 상세화면의 구조만 담당하도록 설계한다.
- "CustomPlayerController", "DetailScreenTabController" 그리고
"LessonInfoController"의 오토레이아웃과 데이터 주고받는 작업만 수행한다.
- 영상 정보를 받아 이곳에 저장하고 하위 Controller에 전달하는 역할을 수행한다.

1. 영상을 담당하는 컨트롤러는 "CustomPlayerController"에서 전담한다.
2. 하단 탭바를 소유한 화면은 "DetailScreenTabController"에서 전담한다.
3. 강의 정보는 "LessonInfoController"에서 전담한다.
*/

import Foundation
import UIKit

class DetailScreenController: UIViewController {
    
    // MARK: - Properties
    
    var videoData = DetailVideoInput(video_id: "15188", token: Constant.token)
    
    private let customPlayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private let detailScreenTabView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    
    // MARK: - Lifecycle
    
    init(videoID: String) {
        super.init(nibName: nil, bundle: nil)
        self.videoData.video_id = videoID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkingAPI()
        configureUI()
    }
    
    
    // MARK: - Actions
    
    
    
    // MARK: - Heleprs
    
    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .black
    }
    
    func configureConstraintAndAddChildController(videoURL: NSURL, vttURL: String, sTagsArray: [String]) {
        let customPlayerVC = CustomPlayerController(videoURL: videoURL, vttURL: vttURL, sTags: sTagsArray)
        let tabVC = DetailScreenTabController()
        
        // 영상재생 컨트롤러를 이 컨트롤러에 추가한다.
        view.addSubview(customPlayerView)
        self.addChild(customPlayerVC)
        customPlayerVC.didMove(toParent: self)
        customPlayerView.addSubview(customPlayerVC.view)
        customPlayerVC.view.frame = customPlayerView.bounds
        let playerHeight =  view.frame.width * 0.57
        customPlayerView.setDimensions(height: playerHeight, width: view.frame.width)
        customPlayerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                left: view.leftAnchor)
        
        // 하단탭바 컨트롤러를 이 컨트롤러에 추가한다.
        self.addChild(tabVC)
        tabVC.didMove(toParent: self)
        detailScreenTabView.addSubview(tabVC.view)
        tabVC.view.frame = detailScreenTabView.bounds
        view.addSubview(detailScreenTabView)
        detailScreenTabView.setDimensions(height: view.frame.height - playerHeight, width: view.frame.width)
        detailScreenTabView.anchor(top: customPlayerView.bottomAnchor,
                                   left:view.leftAnchor)
    }
    
    func networkingAPI() {
        DetailVideoDataManager().DetailScreenDataManager(videoData, viewController: self)
    }
}


// MARK: - API

extension DetailScreenController {
    
    func didSucceedNetworking(response: DetailVideoResponse) {
        // source_url -> VideoURL
        guard let sourceURL = response.data.source_url else { return }
        
        let url = URL(string: sourceURL) as NSURL?

        // sSubtitles -> vttURL
        let vttURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        
        // sTags -> sTagsArray
        let receivedsTagsData = response.data.sTags
        let sTagsArray = receivedsTagsData.split(separator: ",").map { String($0) }
        
        // "sTagsArray"는 String.Sequence이므로 String 선언한 이후 아래 메소드에 할당한다.
        configureConstraintAndAddChildController(videoURL: url ?? NSURL(string: "")!, vttURL: vttURL, sTagsArray: sTagsArray)
    }
}
