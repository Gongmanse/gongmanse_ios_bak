//
//  StoreVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/18.
//
import Foundation
import UIKit
import StoreKit

private let cellId = "StoreCell"

class StoreVC: UIViewController {
    
    // MARK: - Properties
    
    var pageIndex: Int!
    
    let sku: [String] = ["30일", "90일", "150일"]
    
    let purchaseOn: [String] = ["30DayTicketOn","90DayTicketOn","1YearTicketOn"]
    let purchaseOff: [String] = ["30DayTicketOff","90DayTicketOff","1YearTicketOff"]
    
    var buttonText = ""
    
    // MARK: - 결제 관련
    var product: SKProduct?
    var products = [SKProduct]()
    
    var productID = [
        
        "30days",
        "90days_new",
        "1year"
    ]
    
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
        buyButton.isHidden = true
        
        //purchase
        SKPaymentQueue.default().add(self)
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
        return sku.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCell
        cell.layer.cornerRadius = 10
        let buttonImage = UIImage(named: purchaseOn[indexPath.row])
        cell.selectSubscribeButton.setImage(buttonImage, for: .normal)
        cell.selectSubscribeButton.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
        cell.selectSubscribeButton.tag = indexPath.row
        
        return cell
    }
    
    @objc func selectItem(_ sender: UIButton) {
        
        
        switch sender.tag {
        case 0:
            buttonText = "30일"
            break
        case 1:
            buttonText = "90일"
            break
        case 2:
            buttonText = "1년"
            break
        default:
            buttonText = "Non"
            break
        }
        
        let alert = UIAlertController(title: nil, message: "\(buttonText) 이용권을 구매하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "결제", style: .default) { _ in
            // 결제창 연결
            switch sender.tag {
            case 0:
                InAppProducts.store30.requestProducts{ (success,products) in
                    InAppProducts.store30.buyProduct((products?.first)!)
                }
                break
            case 1:
                InAppProducts90.store90.requestProducts{ (success,products) in
                    InAppProducts90.store90.buyProduct((products?.first)!)
                }
                break
            case 2:
                InAppProducts150.store150.requestProducts{ (success,products) in
                    InAppProducts150.store150.buyProduct((products?.first)!)
                }
                break
            default:
                break
            }
            self.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        
        self.present(alert, animated: true, completion: nil)
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

// MARK: - 결제 관련 Delegate

extension StoreVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    public struct InAppProducts {
        public static let product = "30days"
        private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
        public static let store30 = IAPHelper(productIds: InAppProducts.productIdentifiers)
    }
    public struct InAppProducts90 {
        public static let product90 = "90days_new"
        private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts90.product90]
        public static let store90 = IAPHelper(productIds: InAppProducts90.productIdentifiers)
    }
    public struct InAppProducts150 {
        public static let product150 = "1year"
        private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts150.product150]
        public static let store150 = IAPHelper(productIds: InAppProducts150.productIdentifiers)
    }
    
    func getProductInfo(){
        if SKPaymentQueue.canMakePayments(){
            
            let request = SKProductsRequest(productIdentifiers: Set(self.productID))
            request.delegate = self
            request.start()
            
            
            print("겟인포 시작되었습니다.")
        }else{
            print("인앱결제를 활성화해주세요")
        }
        
    }
    
    func getReceiptData () -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                
                
                let receiptString = receiptData.base64EncodedString(options: [])
                
                // Read receiptData
                return receiptString
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
        return nil
    }
    
    func finishBackend (_ receiptData: String) {
        // TODO: URL, API call이 현재 하드코딩 되어있습니다. 코딩 컨벤션에 맞춰 쓰시기 바랍니다.
        let url = URL(string: "\(apiBaseURL)/v2/purchase_ios")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let json: [String: Any] = ["token": Constant.token,
                                   "receipt-data": receiptData]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching films: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // 실패시 처리
                print("Error with the response, unexpected status code: \(response)")
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                }
                return
            }
            // 성공시 처리
            print ("Good!")
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            return
        })
        task.resume()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print (response.products.count);
        products = response.products
        if !products.isEmpty {
            product = products[0] as SKProduct
            //purchase.isEnabled = true //정보 받아오고나서부터는 이거 트루
            
            print("정보를 받아왔습니다.")
        }else{
            print("애플계정에 등록된 상품정보 확인불가")
            
        }
        
        let productList = response.invalidProductIdentifiers
        for productItem in productList{
            print("Product not found : \(productItem)")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as [SKPaymentTransaction]{
            switch transaction.transactionState{
            
            case SKPaymentTransactionState.purchased:
                print("구매했습니다.")
                // self.unlockFeature() //purchased시 실행될 액션
                queue.finishTransaction(transaction)
                if let receiptData = getReceiptData() {
                    finishBackend(receiptData);
                } else {
                    // TODO: 이 경우는 어떤 경우일지 생각해봐야함
                }
                break
                
            case SKPaymentTransactionState.restored:
                print("이미 구매했습니다.")
                //self.unlockFeature() //restore시 실행될 액션
                queue.finishTransaction(transaction)
                // TODO: 실패시 처리
                break
                
            case SKPaymentTransactionState.failed:
                // TODO: 실패시 처리
                queue.finishTransaction(transaction)
            default:
                print("defult")
                break
                
            }
            
        }
    }
}
