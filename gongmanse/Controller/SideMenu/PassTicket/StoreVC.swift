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
        
        // 결제프로세스 진행 중, 서버 동기화 되지 않은 케이스 방어코드
        let isPurchased = UserDefaults.standard.bool(forKey: "purchased")
        if isPurchased {
            print("try upload data")
            if let receiptData = getReceiptData() {
                finishBackend(receiptData);
            }
        } else {
            print("sync done...")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        SKPaymentQueue.default().add(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        SKPaymentQueue.default().remove(self)
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
            // 결제창 연결. 구매 진행중 상태 저장
            switch sender.tag {
            case 0:
                InAppProducts.store30.requestProducts{ (success,products) in
                    UserDefaults.standard.set(true, forKey: "purchased")
                    InAppProducts.store30.buyProduct((products?.first)!)
                }
                break
            case 1:
                InAppProducts90.store90.requestProducts{ (success,products) in
                    UserDefaults.standard.set(true, forKey: "purchased")
                    InAppProducts90.store90.buyProduct((products?.first)!)
                }
                break
            case 2:
                InAppProducts150.store150.requestProducts{ (success,products) in
                    UserDefaults.standard.set(true, forKey: "purchased")
                    InAppProducts150.store150.buyProduct((products?.first)!)
                }
                break
            default:
                break
            }
            self.dismiss(animated: true, completion: nil)

            print("StoreVC show progress")
            showSpinner()
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
    
    
    //MARK: - Consumable products. restore 기능 지원 X
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

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("products.count : \(response.products.count)");
        products = response.products
        if !products.isEmpty {
            for product in products {
                print("products : \(product.localizedDescription)")
            }
            // 구매 상품 설정.
            product = products[0] as SKProduct
        } else {
            print("애플계정에 등록된 상품정보 확인불가")
        }

        let productList = response.invalidProductIdentifiers
        for productItem in productList{
            print("Product not found : \(productItem)")
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
            print("StoreVC hide progress")
            removeSpinner()
            
            if let error = error {
                print("Error with fetching films: \(error)")
                DispatchQueue.main.async {
                    // 21.11.22 영수증 서버등록 실패 시 얼럿 팝업 노출
                    self.showAlert(msg: "서버통신이 원활하지 않습니다.\n\(error.localizedDescription)", okStr: "재시도", okAction: {
                        self.finishBackend(receiptData)
                    }, cancelStr: nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // 실패시 처리
                print("Error with the response, unexpected status code: \((response as! HTTPURLResponse).statusCode)")
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Error Response data string:\n \(dataString)")
                    
                    if dataString.contains("Already Processed Order") {
                        // 이미 등록된 결제키인 경우 패스.
                        print("Already Processed Order")
                        UserDefaults.standard.set(false, forKey: "purchased")
                    } else if dataString.contains("Item does not exists") {
                        //
                        print("Processe canceled")
                        UserDefaults.standard.set(false, forKey: "purchased")
                    } else {
                        // 21.11.22 영수증 서버등록 실패 시 얼럿 팝업 노출
                        DispatchQueue.main.async {
                            self.showAlert(msg: "서버통신이 원활하지 않습니다.\nresponse : \(String(describing: dataString))", okStr: "재시도", okAction: {
                                self.finishBackend(receiptData)
                            }, cancelStr: nil)
                        }
                    }
                }
                return
            }
            
            // 성공시 처리
            print ("Good!")
            UserDefaults.standard.set(false, forKey: "purchased")//결제프로세스 완료
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            return
        })
        task.resume()
    }
    

    // 인앱결제 결과처리
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as [SKPaymentTransaction]{
            switch transaction.transactionState {
            
            case SKPaymentTransactionState.purchased:
                print("SKPaymentTransactionState.purchased")
                queue.finishTransaction(transaction)
                if let receiptData = getReceiptData() {
                    finishBackend(receiptData);
                } else {
                    DispatchQueue.main.async {
                        // 21.11.22 영수증 읽기 실패 시 얼럿 팝업 노출
                        self.showAlert(msg: "구매 영수증을 불러올 수 없습니다.", okStr: "재시도", okAction: {
                            if let receiptData = self.getReceiptData() {
                                self.finishBackend(receiptData);
                            }
                        }, cancelStr: nil)
                    }
                }
                break
                
            case SKPaymentTransactionState.restored:
                //restore. 미제공 (Consumable products, Non-renewable subscriptions)
                print("SKPaymentTransactionState.restored")
                queue.finishTransaction(transaction)
                break
                
            case SKPaymentTransactionState.failed:
                print("SKPaymentTransactionState.failed")
                queue.finishTransaction(transaction)

                UserDefaults.standard.set(false, forKey: "purchased")// 결제프로세스 취소, 완료
                DispatchQueue.main.async {
                    self.showAlert(msg: "결제 실패\n이용권 구매가 취소되었습니다.", okStr: "확인", okAction: {
                        print("이용권 구매 실패, 확인...")
                        removeSpinner()
                    }, cancelStr: nil)
                }
            default:
                print("SKPaymentTransactionState : \(transaction.transactionState)")
                break
                
            }
            
        }
    }
}
