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
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var teachername: UILabel!
    @IBOutlet weak var numberOfPlaylist: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var circleInTagview: UIView!
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configrueCollectionView()
        configurelabel(value: 9)
        
        
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
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(dismissVC))
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
        
        
        // tagView
        tagView.layer.cornerRadius = 10
        circleInTagview.layer.cornerRadius = 7
    }
    
    
    func configurelabel(value: Int) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: "\(value)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfPlaylist.attributedText = attributedString
    }
}


extension TeacherPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeacherPlaylistCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 강사의 플레이리스트 중 클릭 한 강의 플레이리스트로 이동
        let controller = LecturePlaylistVC()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
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
