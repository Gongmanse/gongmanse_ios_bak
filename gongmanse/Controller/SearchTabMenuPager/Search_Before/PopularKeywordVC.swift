//
//  PopularKeywordVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//

import UIKit

private let cellId = "PopularKeywordCell"

// 인기 검색어 cell 클릭 시, 바로 검색결과화면으로 이동하기 위한 Protocol
protocol PopularKeywordVCDelegate: class {
    func filterKeyword(keyword: String)
}

class PopularKeywordVC: UIViewController {

    //MARK: - Properties
    
    weak var delegate: PopularKeywordVCDelegate?
    
    var pageIndex: Int!
    var dummy = searchs     // TODO: 추후에 검색어 순위 데이터 받아올 프로퍼티
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG: PopularKeywordVC Instance")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension PopularKeywordVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PopularKeywordCell
        cell.selectionStyle = .none
        cell.keyword.text = dummy[indexPath.row].title
        
        // cell 좌측 숫자 UI 구현 (SFSymbol 이용)
        let numbering = indexPath.row + 1
        cell.keywordNumber.image = UIImage(systemName: "\(numbering).circle.fill")
        if numbering < 4 {
            cell.keywordNumber.tintColor = .mainOrange
        } else {
            cell.keywordNumber.tintColor = .lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    // 검색어 클릭 시, 해당 검색어로 바로 검색되도록 기능 구현.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.filterKeyword(keyword: dummy[indexPath.row].title)

    }
}
