import UIKit

class RecentVideoTVC: UITableViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var videoTitleLabel = ["파울리의 배타 원리", "전자 배치 규칙", "훈트 규칙"]
    var teachersNameLabel = ["고광윤 선생님", "장기철 선생님", "고광윤 선생님"]
    var upLoadDateLabel = ["1일 전", "1주 전", "1달 전"]
    
    var pageIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        //총 개수 label text 지정
        countAll.text = "총 3개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: "3"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: "3"))
        
        self.countAll.attributedText = attributedString
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentVideoTVCell") as! RecentVideoTVCell
        
        cell.videoTitle.text = videoTitleLabel[indexPath.row]
        cell.teachersName.text = teachersNameLabel[indexPath.row]
        cell.upLoadDate.text = upLoadDateLabel[indexPath.row]
        
        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
