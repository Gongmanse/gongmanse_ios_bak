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
  
    var progressBodyData: [ProgressDetailBody] = []
    var progressIdentifier = ""                             // 서버와 통신할 progressID
    var detailViewTitle = ""
    var detailViewRows = ""
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 총 강의 개수 텍스트 속성 설정
        configurelabel(value: detailViewRows)
        
        // UISwitch 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        navigationItem.title = "진도 학습"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(handleBackBtn))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(UINib(nibName: "ProgressDetailCell", bundle: nil), forCellWithReuseIdentifier: "ProgressDetailCell")
        
        let requestDetailData = ProgressDetailListAPI(progressId: progressIdentifier, limit: 20, offset: 0)
        requestDetailData.requestDetailList { [weak self] result in
            self?.progressBodyData = result
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func handleBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper functions
    
    func configurelabel(value: String) {
        
        // 제목 타이틀 텍스트
        lessonTitle.text = detailViewTitle
        
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
        return progressBodyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressDetailCell", for: indexPath) as? ProgressDetailCell else { return UICollectionViewCell() }
        
        let progressIndexPath = progressBodyData[indexPath.row]
        
        let urlEncoding = progressIndexPath.thumbnail?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        cell.subjectSecond.isHidden = progressIndexPath.unit != nil ? false : true
        
        cell.lessonImage.setImageUrl(urlEncoding ?? "")
        cell.lessonTitle.text = progressIndexPath.title
        cell.subjectFirst.text = progressIndexPath.subject
        cell.subjectSecond.text = progressIndexPath.unit
        cell.starRating.text = progressIndexPath.rating
        cell.subjectFirst.backgroundColor = UIColor(hex: progressIndexPath.subjectColor ?? "")
        cell.subjectSecond.backgroundColor = .mainOrange
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
