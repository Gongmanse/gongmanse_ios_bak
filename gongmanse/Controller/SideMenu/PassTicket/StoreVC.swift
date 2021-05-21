//
//  StoreVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/18.
//

import UIKit

private let cellId = "StoreCell"

class StoreVC: UIViewController {
    
    // MARK: - Properties
    
    var pageIndex: Int!

    let sku: [String] = ["30일", "90일", "150일"]
    
    let purchaseOn: [String] = ["30DayTicketOn","90DayTicketOn","150DayTicketOn"]
    let purchaseOff: [String] = ["30DayTicketOff","90DayTicketOff","150DayTicketOff"]
    
    // MARK: - IBOutlet
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buyButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    
    // MARK: - Actions
    
    @IBAction func handleBuy(_ sender: Any) {
        print("DEBUG: clicked Button")
    }
    
    
    
    
    // MARK: - Helper functions
    func configureUI() {
        // descriptionLabel
        descriptionLabel.font = UIFont.appBoldFontWith(size: 14)
        descriptionLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        descriptionLabel.setDimensions(height: view.frame.height * 0.2,
                                       width: view.frame.width * 0.82)
        descriptionLabel.centerX(inView: view)
        descriptionLabel.anchor(top: view.topAnchor,
                                paddingTop: 1)
        
        // collectionView
        collectionView.anchor(top: descriptionLabel.bottomAnchor,
                              left: descriptionLabel.leftAnchor,
                              right: descriptionLabel.rightAnchor,
                              paddingTop: 10,
                              height: view.frame.height * 0.58)
        
        // buyButton
        buyButton.layer.cornerRadius = 8
        buyButton.centerX(inView: descriptionLabel)
        buyButton.anchor(left: descriptionLabel.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: descriptionLabel.rightAnchor,
                         height: view.frame.height * 0.05)
        buyButton.addShadow()
        
    }


}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension StoreVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCell
        cell.layer.cornerRadius = 10
        let buttonImage = UIImage(named: purchaseOn[indexPath.row])
        cell.selectSubscribeButton.setImage(buttonImage, for: .normal)
//        cell.selectSubscribeButton.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
        cell.selectSubscribeButton.tag = indexPath.row
        
        return cell
    }
    
    @objc func selectItem(_ sender: UIButton) {
//        switch sender.tag {
//        case 0:
//            var isSelect = true
//
//
//        default:
//            <#code#>
//        }
    }
    
    
    
}


//MARK: - UICollectionViewDelegateFlowLayout

extension StoreVC: UICollectionViewDelegateFlowLayout {

    
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        let padding = self.view.frame.width * 0.035
        return 3
    }

    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 40, height: 100)
    }

}
