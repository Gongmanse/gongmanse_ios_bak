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

    
    weak var delegate: RecentKeywordVCDelegate?
    
    var pageIndex: Int!
    
    // 검색어 관련 로직 프로퍼티
    
    var removeDuplicatedData: [String] {
        return removeDuplicate(searchKeywordRecord)
    }
    
    lazy var searchKeywordRecord = [String]() {
        didSet { checkEmptyConfigure() }
    } 
    
    var isKeywordLog: Bool = false               // 검색내역이 있는지 없는지 확인하는 Index

    // viewModel
    let recentVM:RecentKeywordViewModel = RecentKeywordViewModel()
    
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
        tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        
        
        recentVM.requestGetListApi()
    }
    
    //MARK: - Helper functions
    
    // "searchKeywordRecord" 데이터 존재 여부에 따라서 이미지를 표현할지 말지에 대해 결정하는 메소드.
    func checkEmptyConfigure() {
        if recentVM.recentKeywordList?.data.count == 0 {
           // EmptyData
        } else {
            isKeywordLog = true
        }
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension RecentKeywordVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return isKeywordLog ? recentVM.recentKeywordList?.data.count ?? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isKeywordLog {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordCell", for: indexPath) as? RecentKeywordCell else { return UITableViewCell() }
            
            let recentList = recentVM.recentKeywordList?.data[indexPath.row]

            // ID와 word를 묶기 위한 Tuple사용
            let tuples: (id:String, word:String, tag:Int) = (recentList?.id ?? "", recentList?.sWords ?? "", indexPath.row)
            
            cell.selectionStyle = .none
            
            cell.keyword.text = tuples.word
            cell.date.text = recentList?.convertDate
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
        
        guard let removeText = recentVM.recentKeywordList?.data[sender.tag].id else { return }
        recentVM.requestDeleteKeywordApi(removeText)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isKeywordLog {
            return 44
        } else {
            return tableView.frame.height - 100 // 추후에 변경해야할 부분. EmptyView의 Message가 정가운데 올 수 있도록.
        }
    }
    
}


//MARK: - RecentKeywordCellDelegate
// Cell 삭제 로직 구현. RecentKeywordCell에서 사용됨.
// Cell의 X버튼을 누르면 해당 메소드가 호출되어야 하므로.

extension RecentKeywordVC: RecentKeywordCellDelegate {
    func deleteCell(indexPath: IndexPath) {
        if isKeywordLog {
        
            // 각각의 Dataset의 데이터 삭제
            self.searchKeywordRecord.remove(at: indexPath.row)              // 'SearchVC'로부터 전달받은 프로퍼티 데이터 삭제
            
            let path = IndexPath(row: indexPath.row, section: 0)
            // TableView cell 삭제
            tableView.deleteRows(at: [path], with: .automatic)         // 테이블 뷰의 해당 cell을 삭제
            if indexPath.row == 0 {              
                self.isKeywordLog = false
                tableView.reloadData()
            }
        }
    }
}



extension RecentKeywordVC: ReloadDataInRecentKeywordVCDelegate {
    func finalReload() {
        // TODO: 최초 계획은 Delegation을 이용한 ReloadData할 계획인데 원하는대로 되지 않음. 
        // 다른 방법으로는 다시 돌아와도 첫 화면이 인기검색어로 하여 무조건 ReloadData 되도록 처리하는 방법이 있음.
        self.tableView.reloadData()
        print("DEBUG: final Delegate is successed")
    }
    
    
}

extension RecentKeywordVC: TableReloadData {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


