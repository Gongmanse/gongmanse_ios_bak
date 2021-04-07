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
  
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 총 강의 개수 텍스트 속성 설정
        configurelabel(value: 32) 
        
        // UISwitch 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        navigationItem.title = "진도 학습"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(handleBackBtn))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(UINib(nibName: "ProgressDetailCell", bundle: nil), forCellWithReuseIdentifier: "ProgressDetailCell")
        
    }
    
    //MARK: - Actions
    
    @objc func handleBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper functions
    
    func configurelabel(value: Int) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: "\(value)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: "개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfLesson.attributedText = attributedString
    }
}







//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ProgressDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressDetailCell", for: indexPath) as! ProgressDetailCell
        return cell
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
