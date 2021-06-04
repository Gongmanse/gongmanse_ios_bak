//
//  RatingController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/31.
//

import UIKit

protocol RatingControllerDelegate: AnyObject {
    func ratingAvaergePassVC(rating: String)
}

class RatingController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: RatingControllerDelegate?
    
    // 클릭된 별표의 위치를 저장할 프로퍼티
    var clickedNumber = 3 {
        didSet { setupButtonTintColor(point: clickedNumber, color: .mainOrange)}
    }
    
    var videoID: Int?
    
    // IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var forthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    @IBOutlet weak var ratingLeftLabel: UILabel!
    @IBOutlet weak var numberOfParticipantsLabel: UILabel!
    @IBOutlet weak var dividerLineView: UIView!
    @IBOutlet weak var ratingPointLabel: UILabel!
    
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
    
    
    // MARK: - Actions
    
    @IBAction func tapXButton(_ sender: Any) {
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
                                    rating: clickedNumber)
        
        RatingDataManager().addRatingToVideo(inputData,
                                             viewController: self)
        dismiss(animated: false)
    }
    
    @IBAction func tapStarShapPointButton(_ sender: UIButton) {
        setupButtonTintColor(point: self.clickedNumber,
                             color: .black)
        clickedNumber = sender.tag
    }
    
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        titleLabel.font = UIFont.appBoldFontWith(size: 20)
        setupButtonTintColor(point: 5, color: .black)
        ratingLeftLabel.font = UIFont.appRegularFontWith(size: 13)
        ratingContainerView.layer.cornerRadius = 7.5
        applyButton.layer.cornerRadius = 7
        numberOfParticipantsLabel.textColor = .mainOrange
        dividerLineView.backgroundColor = .mainOrange
    }
    
    func networkingAPI() {
        
        if let videoID = self.videoID {
            let inputData = DetailVideoInput(video_id: "\(videoID)",
                                             token: Constant.token)
            DetailVideoDataManager().apiPassRatingDataToRatingVC(inputData,
                                                                 viewController: self)
        }
    }
    
    func setupButtonTintColor(point: Int, color: UIColor) {
        // 입력한 point의 숫자만큼 그 숫자에 해당하는 tag 값의 tintColor를 변경한다.
        let tagNumber = point
        for tagNum in 1 ... tagNumber {
            let view = self.view.viewWithTag(tagNum)
            view?.tintColor = color
        }
        
        self.ratingPointLabel.text = String(point) + ".0"
    }
    

}


// MARK: - API

extension RatingController {
    
    func didSuccessNetworking(response: DetailVideoResponse) {
        
        // 사용자가 평가한 평점
        let ratingLesson = response.data.iRating
        ratingPointLabel.text = ratingLesson + ".0"
        
        let convertRatingLesson = Float(ratingLesson)
        
        setupButtonTintColor(point: Int(convertRatingLesson!), color: .mainOrange)
        
        // 이 강의에 평가한 인원수
        let numberOfRating = response.data.iRatingNum
        numberOfParticipantsLabel.text = numberOfRating + " 명"
        
        // 강의의 평점
        if let ratingaAverage = response.data.iUserRating {
            delegate?.ratingAvaergePassVC(rating: ratingaAverage)
        }
    }
}
