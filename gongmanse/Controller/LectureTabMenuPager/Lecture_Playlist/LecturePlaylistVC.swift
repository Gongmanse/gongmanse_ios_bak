//
//  LecturePlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

private let cellId = "LectureCell"

class LecturePlaylistVC: UIViewController {

    // MARK: - Properties
    
    var seriesID: String?
    var detailVM: LectureDetailViewModel? = LectureDetailViewModel()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var titleText: UILabel!
    
    // MARK: - Lifecylce
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let totalNum = detailVM?.lectureDetail?.totalNum
        configurelabel(value: totalNum ?? "")
        titleText.text = detailVM?.lectureDetail?.seriesInfo?.sTitle
        teacherName.text = detailVM?.lectureDetail?.seriesInfo?.sTeacher
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
    }

    
    
    // MARK: - Actions
    
    // 뒤로가기 버튼 로직
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        // tagView
        tagView.layer.cornerRadius = 10
        circleView.layer.cornerRadius = 7
        
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
        return detailVM?.lectureDetail?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LectureCell
        guard let detailData = detailVM?.lectureDetail?.data[indexPath.row] else { return UICollectionViewCell() }
        cell.setCellData(detailData)
        return cell
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
