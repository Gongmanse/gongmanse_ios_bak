//
//  HighSchoolVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit

private let cellId = "CurriculumCell"

class HighSchoolVC: UIViewController {

    //MARK: - Properties
    
    var pageIndex: Int!
    
    var highVM: LectureTapViewModel? = LectureTapViewModel()
    
    var listCount: Int = 0
    //MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configrueCollectionView()
        highVM?.reloadDelgate = self
        highVM?.lectureListGetApi(grade: "고등", offset: "0")
    }

    //MARK: - Actions
    
    func configrueCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)

    }
    
}
extension HighSchoolVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return highVM?.lectureList?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CurriculumCell
        
        let indexData = highVM?.lectureList?.data[indexPath.row]
        let images = "\(fileBaseURL)/\(indexData?.sThumbnail ?? "")"
        
        //0707 - edited by hp
        cell.lectureImage.contentMode = .scaleAspectFill
        cell.lectureImage.setImageUrl(images)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: Test
//        let vc = DetailScreenController(videoID: "46644")
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true)
        
        
        // 클릭 시 선생별 플레이리스트 화면으로 이동
        // 추후에 아래 코드로 상세페이지 화면전환한다 - 영상페이지 테스트를 위한 임시 주석처리
        guard let postData = highVM?.lectureList?.data[indexPath.row] else { return }
        let vc = TeacherPlaylistVC(postData)
        
        vc.instructorID = postData.id
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.appEBFontWith(size: 17)]   // Naivagation title 폰트설정
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = highVM?.lectureList?.data.count else { return }
        
        if indexPath.row == cellCount - 1 {
            listCount += 20
            highVM?.lectureListGetApi(grade: "고등", offset: "\(listCount)")
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension HighSchoolVC: UICollectionViewDelegateFlowLayout {

    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        
        //0707 - edited by hp
        return CGSize(width: width, height: (width / 16 * 9))
    }

}

extension HighSchoolVC: CollectionReloadData {
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

