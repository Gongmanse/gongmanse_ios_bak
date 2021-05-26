//
//  LecturePlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

enum LectureState {
    case lectureList
    case videoList
}

private let cellId = "LectureCell"

class LecturePlaylistVC: UIViewController {

    // MARK: - Properties
    
    var lectureState: LectureState?
    
    // 강사별 강의
    var getTeacherList: LectureSeriesDataModel?
    var seriesID: String?
    var totalNum: String?
    var gradeText: String?
    var detailVM: LectureDetailViewModel? = LectureDetailViewModel()

    
    // 관련시리즈
    lazy var videoNumber: String = ""
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var colorView: UIStackView!
    
    // MARK: - Lifecylce
    
    // 강사별강의에서 값 넘겨받음
    init(_ teacherModel: LectureSeriesDataModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.getTeacherList = teacherModel
    }
    
    // 비디오 영상에서 ID받음
    init(_ videoID: String) {
        super.init(nibName: nil, bundle: nil)
            
        videoNumber = videoID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if videoNumber != "" {
            let seriesInfo = detailVM?.relationSeriesList?.seriesInfo
            
            titleText.text = seriesInfo?.sTitle
            teacherName.text = "\(seriesInfo?.sTeacher ?? "") 선생님"
            subjectLabel.text = seriesInfo?.sSubject
            gradeLabel.text = detailVM?.convertGrade(seriesInfo?.sGrade)
            gradeLabel.textColor = UIColor(hex: seriesInfo?.sSubjectColor ?? "000000")
            colorView.backgroundColor = UIColor(hex: seriesInfo?.sSubjectColor ?? "000000")
            configurelabel(value: detailVM?.relationSeriesList?.totalNum ?? "")
            self.navigationItem.title = "S"
        }
        
        // 테이블 위쪽 View 데이터
        if let getTeacher = getTeacherList {
            
            configurelabel(value: totalNum ?? "")
            
            titleText.text = getTeacher.sTitle
            teacherName.text = "\(getTeacher.sTeacher ?? "") 선생님"
            subjectLabel.text = getTeacher.sSubject
            gradeLabel.text = detailVM?.convertGrade(gradeText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavi()             // navigation 관련 설정
        configureUI()               // 태그 UI 설정
        collectionView.delegate = self
        collectionView.dataSource = self
        

        // UISwitch UI 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        detailVM?.lectureDetailApi(seriesID ?? "")
        detailVM?.delegate = self
        
        
        if videoNumber != "" {
            detailVM?.relationSeries(videoNumber)
        }
    }

    
    
    // MARK: - Actions
    
    // 뒤로가기 버튼 로직
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white

        // gradeLabel
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 8.5
        gradeLabel.textColor = UIColor(hex: getTeacherList?.sSubjectColor ?? "000000")
        
        // subjectColor
        colorView.backgroundColor = UIColor(hex: getTeacherList?.sSubjectColor ?? "000000")
        colorView.layer.cornerRadius = colorView.frame.size.height / 2
        colorView.layoutMargins = UIEdgeInsets(top: 2, left: 10, bottom: 3, right: 10)
        colorView.isLayoutMarginsRelativeArrangement = true
        
        titleText.font = .appEBFontWith(size: 17)
        teacherName.font = .appBoldFontWith(size: 12)
    }
    
    func configureNavi() {
        let title = UILabel()
        title.text = "강사별 강의"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        
        // navigationItem Back button
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = backButton
    }
    
    
    // UILabel 부분 속성 변경 메소드
    func configurelabel(value: String) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        
        attributedString.append(NSAttributedString(string: value,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: " 개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfLesson.attributedText = attributedString
    }

}


extension LecturePlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch lectureState {
        
        case .lectureList:
            return detailVM?.lectureDetail?.data.count ?? 0
            
        case .videoList:
            return detailVM?.relationSeriesList?.data.count ?? 0
            
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch lectureState {
        case .lectureList:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LectureCell
            guard let detailSeriesData = detailVM?.lectureDetail?.data[indexPath.row] else {
                return UICollectionViewCell() }
            
            cell.setSeriesCellData(detailSeriesData)
            
            return cell
        case .videoList:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LectureCell
            guard let detailVideoData = detailVM?.relationSeriesList?.data[indexPath.row] else {
                return UICollectionViewCell() }
            
            cell.setVideoCellData(detailVideoData)
            
            return cell
        default:
            return UICollectionViewCell()
        }

    }
    
    
}


//MARK: - UICollectionViewDelegateFlowLayout

extension LecturePlaylistVC: UICollectionViewDelegateFlowLayout {

    
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let padding = self.view.frame.width * 0.035
        return padding
    }

    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }

    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = self.view.frame.width * 0.035
        let width = view.frame.width - (padding * 2)
        return CGSize(width: width, height: width * 0.66)
    }

}

extension LecturePlaylistVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
