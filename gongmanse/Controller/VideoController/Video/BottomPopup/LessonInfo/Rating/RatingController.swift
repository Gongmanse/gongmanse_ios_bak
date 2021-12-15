//
//  RatingController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/31.
//

import UIKit
import Cosmos

protocol RatingControllerDelegate: AnyObject {
    func ratingAvaergePassVC(rating: String)
    func dismissRatingView()
}

class RatingController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: RatingControllerDelegate?
    
    var initPoint: Int = 3
    
    var userRating: String?
    
    var myRating: String?
    
    var videoID: Int?
    
    // IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var ratingLeftLabel: UILabel!
    @IBOutlet weak var numberOfParticipantsLabel: UILabel!
    @IBOutlet weak var dividerLineView: UIView!
    @IBOutlet weak var ratingPointLabel: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    
    // MARK: - Lifecycle
    
    convenience init(videoID: Int) {
        self.init()
        self.videoID = videoID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        setupLayout()
        networkingAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 초기값을 3 점으로 할당한다
        if myRating == nil {
            for i in 1...3 {
                view.viewWithTag(i)?.tintColor = .mainOrange
            }
            ratingPointLabel.text = "3.0"
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func tapXButton(_ sender: Any) {
        
        // Default 점수는 3 점
//        guard let videoID = self.videoID else { return }
//        let inputData = RatingInput(token: Constant.token,
//                                    video_id: videoID,
//                                    rating: clickedNumber)
//
//        RatingDataManager().addRatingToVideo(inputData,
//                                             viewController: self)
//
//        // 종료하더라도 기본값을 3 을 준다.
//        delegate?.ratingAvaergePassVC(rating: "\(clickedNumber)")

        delegate?.dismissRatingView()
        UIView.animate(withDuration: 0.33) {
            self.view.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func tapApplyButton(_ sender: Any) {
        
        // API를 호출하여 평점을 등록한다.
        guard let videoID = self.videoID else { return }
        let inputData = RatingInput(token: Constant.token,
                                    video_id: videoID,
                                    rating: Int(ratingBar.rating))
        
        RatingDataManager().addRatingToVideo(inputData,
                                             viewController: self)
    }
    // 평점 등록, 응답대기 후에 정보 요청하도록 수정
    func refreshUserRating() {
        delegate?.ratingAvaergePassVC(rating: "\(Int(ratingBar.rating))")
        
        dismiss(animated: false)
        // 유저가 평점을 줬다면,
        // 1. dismiss 이후에, 모든 회원들의 평균 점수가 보여야한다.
        // 2. 버튼이 .mainOrange로 변경되어야한다.
    }
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        titleLabel.font = UIFont.appBoldFontWith(size: 20)
        
        // 별점 초기값.
        for i in 1...5 {
            view.viewWithTag(i)?.tintColor = .black
        }
        
        ratingLeftLabel.font = UIFont.appRegularFontWith(size: 13)
        ratingLeftLabel.adjustsFontSizeToFitWidth = true
        numberOfParticipantsLabel.adjustsFontSizeToFitWidth = true
        ratingContainerView.layer.cornerRadius = 7.5
        applyButton.layer.cornerRadius = 7
        numberOfParticipantsLabel.textColor = .mainOrange
        dividerLineView.backgroundColor = .mainOrange
        
        ratingBar.rating = Double(initPoint)
        ratingBar.didFinishTouchingCosmos = { rating in
            self.ratingPointLabel.text = String(rating)
        }
    }
    
    func networkingAPI() {
        
        if let videoID = self.videoID {
            let inputData = DetailVideoInput(video_id: "\(videoID)",
                                             token: Constant.token)
            
            // 이 API는 동영상 상세정보 API인데 그 중 평점 데이터만 가져오기 위해서 호출한다.
            DetailVideoDataManager().apiPassRatingDataToRatingVC(inputData,
                                                                 viewController: self)
        }
    }
    
    func setupButtonTintColor(point: Int, color: UIColor) {
        // 1. DEFAULT SETTING : 별 모양 버튼을 모두 검정으로 설정한다.
        for i in 1...5 {
            view.viewWithTag(i)?.tintColor = .black
        }

        // 2. "point" 값 만큼 색상을 변경한다.
        for i in 1...point {
            view.viewWithTag(i)?.tintColor = .mainOrange
        }
    }
    
}


// MARK: - API

extension RatingController {
    
    /// 평점 View 최초 접속 때, 호출되는 메소드
    func didSuccessNetworking(response: DetailVideoResponse) {
        
        // 사용자가 평가한 평점
        // 만약 사용자가 평가한 기록이 있다면, 그 기록을 별점만큼 색칠하고
        // 텍스트에 그 점수를 보여준다.
        if let myRating = response.data.iUserRating {
            self.ratingPointLabel.text = myRating + ".0"
            setupButtonTintColor(point: Int(myRating) ?? 2, color: .mainOrange)
        }
        
        // 이 강의에 평가한 인원수
        let numberOfRating = response.data.iRatingNum
        numberOfParticipantsLabel.text = numberOfRating + " 명"
    }
}
