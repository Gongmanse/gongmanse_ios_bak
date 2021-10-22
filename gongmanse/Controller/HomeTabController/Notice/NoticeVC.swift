import UIKit

class NoticeVC: UITableViewController {
    
    var notice: NoticeModels?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "알림"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        getDataFromJson()
    }
    
    func getDataFromJson() {
        if let url = URL(string: "\(apiBaseURL)/v3/notice?token=\(Constant.token)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(NoticeModels?.self, from: data) {
                    print(json.data)
                    self.notice = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }.resume()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.notice?.data else { return 0}
        return data.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTVCell", for: indexPath) as? NoticeTVCell else { return UITableViewCell() }
        
        guard let json = self.notice else { return cell }
        let indexData = json.data[indexPath.row]
        guard let timeCutString = indexData.dtDateCreated else { return cell}
        let timeString: String.Index = timeCutString.index(timeCutString.startIndex, offsetBy: 10)
        let resultValue = String(timeCutString[timeString...])
        let resultValueSecond = String(timeCutString[...timeString])
        
        cell.noticeTitle.text = indexData.sBody
        cell.noticeDate.text = resultValueSecond
        cell.noticeTime.text = resultValue
        cell.noticeBigTitle.text = "[\(indexData.sTitle ?? "nil")]"
        
        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
