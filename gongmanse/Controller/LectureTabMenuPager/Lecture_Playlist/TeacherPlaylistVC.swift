//
//  TeacherPlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit
private let cellId = "TeacherPlaylistCell"

class TeacherPlaylistVC: UIViewController {

    //MARK: - Properties
    
    // 시리즈 ID 받을 변수
    var instructorID: String?
    
    
    let seriesVM = LectureTapViewModel()
    
    var lecturelist: LectureDataModel?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var teachername: UILabel!
    @IBOutlet weak var numberOfPlaylist: UILabel!
    @IBOutlet weak var colorView: UIStackView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    init(_ lectureList: LectureDataModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.lecturelist = lectureList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let lectureDataList = lecturelist {

            teachername.text = "\(lectureDataList.sTeacher) 선생님"
            colorView.backgroundColor = UIColor(hex: "\(lectureDataList.sSubjectColor)")
            gradeLabel.text = seriesVM.convertGrade(lectureDataList.sGrade)
            subjectLabel.text = lectureDataList.sSubject
            
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        configurelabel(value: "\(seriesVM.lectureSeries?.totalNum ?? 0)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configrueCollectionView()
        
        
        seriesVM.lectureSeriesApi(instructorID ?? "")
        seriesVM.reloadDelgate = self
    }

    //MARK: - Actions
    
    func configrueCollectionView() {
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)    
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    func configureUI() {
        // navigationItem Back button
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "강사별 강의"
        
        // teachername
        teachername.setDimensions(height: upperView.frame.height * 0.286,
                                  width: upperView.frame.width * 0.272)
        teachername.anchor(top: upperView.topAnchor,
                           left: upperView.leftAnchor,
                           paddingTop: upperView.frame.height * 0.25,
                           paddingLeft: upperView.frame.width * 0.035)
        
        // numberOfPlaylist
        numberOfPlaylist.setDimensions(height: teachername.frame.height * 0.9,
                                       width: teachername.frame.width * 0.5)
        numberOfPlaylist.anchor(top: teachername.bottomAnchor,
                                left: teachername.leftAnchor,
                                paddingTop: 5)

        
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white

        // gradeLabel
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 8.5
        gradeLabel.textColor = UIColor(hex: lecturelist?.sSubjectColor ?? "000000")
        
        // subjectColor
        colorView.backgroundColor = .mainOrange
        colorView.layer.cornerRadius = colorView.frame.size.height / 2
        colorView.layoutMargins = UIEdgeInsets(top: 2, left: 10, bottom: 3, right: 10)
        colorView.isLayoutMarginsRelativeArrangement = true
        

    }
    
    
    func configurelabel(value: String) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: value,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfPlaylist.attributedText = attributedString
    }
}


extension TeacherPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seriesVM.lectureSeries?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeacherPlaylistCell
        
        guard let indexData = seriesVM.lectureSeries?.data[indexPath.row] else { return UICollectionViewCell()}
        
        cell.setCell(indexData)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 강사의 플레이리스트 중 클릭 한 강의 플레이리스트로 이동
        guard let postData = seriesVM.lectureSeries?.data[indexPath.row] else { return }
        
        let controller = LecturePlaylistVC(postData)
        controller.seriesID = seriesVM.lectureSeries?.data[indexPath.row].iSeriesId
        controller.totalNum = postData.iCount
        controller.gradeText = lecturelist?.sGrade
        controller.lectureState = .lectureList
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(controller, animated: true)
        self.present(nav, animated: true)
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension TeacherPlaylistVC: UICollectionViewDelegateFlowLayout {

    
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

extension TeacherPlaylistVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionview.reloadData()
        }
    }
}
