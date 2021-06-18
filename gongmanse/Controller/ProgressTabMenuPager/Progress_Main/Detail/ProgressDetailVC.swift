//
//  ProgressDetailVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/09.
//

import UIKit

class ProgressDetailVC: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var lessonTitle: UILabel!                // 어떤 강의인지 viewModel을 통해 전달받아야함.
    @IBOutlet weak var numberOfLesson: UILabel!             // 몇 개의 강의가 있는지 viewModel을 통해 전달받아야함. 
    @IBOutlet weak var collectionView: UICollectionView!    
    @IBOutlet weak var autoPlaySwitch: UISwitch!
  
    @IBOutlet weak var subjectColor: UIStackView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
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
        
        navigationItem.title = "진도 학습"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(handleBackBtn))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(UINib(nibName: detailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: detailCellIdentifier)
        
        progressDataManager(progressID: progressIdentifier, limit: 20, offset: 0)
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
        subjectColor.layoutMargins = UIEdgeInsets(top: 2, left: 10, bottom: 3, right: 10)
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
        
        cell.lessonImage.setImageUrl(progressIndexPath?.thumbnail ?? "")
        cell.lessonTitle.text = progressIndexPath?.title
        cell.subjectFirst.text = progressIndexPath?.subject
        cell.subjectSecond.text = progressIndexPath?.unit
        cell.starRating.text = progressIndexPath?.rating
        
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
        
        if Constant.isLogin {
            // 비디오 연결
            let vc = VideoController()
            let videoDataManager = VideoDataManager.shared
            videoDataManager.isFirstPlayVideo = true
            let receviedVideoID = self.progressBodyData?[indexPath.row].videoId
            vc.id = receviedVideoID
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            return
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
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
        let width = view.frame.width
        return CGSize(width: width, height: 240)
    }
    
}
