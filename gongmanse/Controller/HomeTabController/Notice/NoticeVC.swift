import UIKit

class NoticeVC: UITableViewController {
    
    var titleLabels = ["알림 테스트", "공만세 회원 공지"]
    var dateLabels = ["2021.01.22", "2020.11.09"]
    var timeLabels = ["오후 14:55", "오후 12:34"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "알림"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "NoticeTVCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) as! NoticeTVCell
        
        cell.noticeTitle.text = titleLabels[indexPath.row]
        cell.noticeDate.text = dateLabels[indexPath.row]
        cell.noticeTime.text = timeLabels[indexPath.row]

        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
