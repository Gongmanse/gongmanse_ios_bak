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
    }

    
    // MARK: - Helper functions
    
    
    
}


extension PaymentHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPaymentHistory ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPaymentHistory {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PaymentHistoryCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateViewCell", for: indexPath) as! EmptyStateViewCell
            cell.alertMessage.text = "결제 내역이 없습니다."
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isPaymentHistory ? view.frame.height * 0.107 : tableView.frame.height
    }
    
}
