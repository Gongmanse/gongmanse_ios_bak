//
//  RecentKeywordVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/10.
//
// TODO: 검색관련 API와 연결하여 검색어 삭제 및 빈 페이지 보여주는 로직 처리할 것.

import UIKit

// 검색결과화면 -> 초기검색화면 으로 돌아올 때, 최근 검색어 reloadData 기능 구현을 위한 Protocol
protocol RecentKeywordVCDelegate: class {
    func reloadTableView(tv: UITableView)
}

class RecentKeywordVC: UIViewController {
    
    //MARK: - Properties
    var comeFromSearchVC: Bool = true
    
    weak var delegate: RecentKeywordVCDelegate?
    
    var pageIndex: Int!

    // viewModel
    let recentVM:RecentKeywordViewModel = RecentKeywordViewModel()
    
    // singleton
    lazy var searchData: SearchData = SearchData.shared
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print("DEBUG: RecentKeyword Instance")
        
        // TableView Setting
        tableView.delegate = self
        tableView.dataSource = self
        recentVM.reloadDelegate = self
        
        tableView.register(UINib(nibName: "RecentKeywordCell", bundle: nil), forCellReuseIdentifier: "RecentKeywordCell")
        tableView.register(UINib(nibName: "EmptyStateViewCell", bundle: nil), forCellReuseIdentifier: "EmptyStateViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .none
        
        
        recentVM.requestGetListApi()
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension RecentKeywordVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchData.isToken ? recentVM.recentList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if searchData.isToken {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordCell", for: indexPath) as? RecentKeywordCell else { return UITableViewCell() }
            
            let recentList = recentVM.recentList[indexPath.row]

            // ID와 word를 묶기 위한 Tuple사용
            let tuples: (id:String, word:String, tag:Int) = (recentList.id ?? "", recentList.sWords ?? "", indexPath.row)
            
            cell.selectionStyle = .none
            
            cell.keyword.text = tuples.word
            cell.date.text = recentList.convertDate
            cell.deleteButton.addTarget(self, action: #selector(deleteWord(_:)), for: .touchUpInside)
            cell.deleteButton.tag = tuples.tag
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateViewCell", for: indexPath) as? EmptyStateViewCell else { return UITableViewCell() }
            
            let imageView = UIImageView(image: UIImage(named: "alert"))
            imageView.contentMode = .center
            cell.backgroundView = imageView
            cell.alertMessage.text = "검색 내역이 없습니다."
            cell.selectionStyle = .none

            return cell
        }
        
    }
    
    @objc func deleteWord(_ sender: UIButton) {
        
        guard let removeText = recentVM.recentList[sender.tag].id else { return }
        recentVM.requestDeleteKeywordApi(removeText)
        
        recentVM.recentList.remove(at: sender.tag)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchData.isToken {
            return 44
        } else {
            return tableView.frame.height - 100 // 추후에 변경해야할 부분. EmptyView의 Message가 정가운데 올 수 있도록.
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchData.isToken {
            searchData.searchText = recentVM.recentList[indexPath.row].sWords
            
            // 선택시 검색창 text생성하기
            NotificationCenter.default.post(name: .searchBeforeSearchBarText, object: nil)
            
            // 화면이동하는 Controller로 데이터 전달
            let controller = SearchAfterVC()
            
            controller.comeFromSearchVC = self.comeFromSearchVC
            
            // 화면 전환
            let vc = UINavigationController(rootViewController: controller)
            
            vc.modalPresentationStyle = .fullScreen
            
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == recentVM.recentList.count - 1 && !recentVM.isLoading {
            //더보기
            recentVM.requestGetListApi(recentVM.recentList.count)
        }
    }
}

extension RecentKeywordVC: TableReloadData {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


