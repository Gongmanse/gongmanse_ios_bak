//
//  PaymentHistoryVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/18.
//

import UIKit

private let cellId = "PaymentHistoryCell"


class PaymentHistoryVC: UIViewController {

    // MARK: - Properties
    
    var pageIndex: Int!
    var isPaymentHistory: Bool = false  // 구매내역이 있는지 확인하는 Index
    var tableViewInputData: [PurchaseData] = []
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.register(UINib(nibName: "EmptyStateViewCell", bundle: nil), forCellReuseIdentifier: "EmptyStateViewCell")
        tableView.tableFooterView = UIView()
        
        tableViewInputData.removeAll()
        getPaymentHistory(offset: 0)
    }

    
    // MARK: - Helper functions
    var isLoading = false
    var paymentHistory: Purchase?
    private func getPaymentHistory(offset: Int) {
        print("Payment getPaymentHistory : \(offset)")
        if let url = URL(string: "\(apiBaseURL)/v/payment/purchasehistory?token=\(Constant.token)&offset=\(offset)&limit=20") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            print("url : \(url)")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(Purchase.self, from: data) {
                    print("json.data : \(json.data), cnt : \(json.data.count)")
                    self.tableViewInputData.append(contentsOf: json.data)
                    self.paymentHistory = json
                    self.isPaymentHistory = true
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }.resume()
        }
    }
}


extension PaymentHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPaymentHistory && tableViewInputData.count > 0 ? tableViewInputData.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPaymentHistory && tableViewInputData.count > 0{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PaymentHistoryCell
            let item = tableViewInputData[indexPath.row]
            
            cell.paymentDate.text = "결제일 | \(item.dtInitiateDate)"
            cell.passLabel.text = "\(item.iDuration)일 이용권"
            cell.price.text = item.iPrice.withCommas()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateViewCell", for: indexPath) as! EmptyStateViewCell
            cell.alertMessage.text = "준비중 입니다.."
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isPaymentHistory ? view.frame.height * 0.107 : tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.tableViewInputData.count - 1
            && !self.isLoading
            && self.tableViewInputData.count < (Int(self.paymentHistory?.totalNum ?? "0") ?? 0) {
            //더보기
            print("paymentHistory tableViewInputData : \(self.tableViewInputData.count), isLoading : \(self.isLoading)")
            getPaymentHistory(offset: self.tableViewInputData.count)
        }
    }
}
