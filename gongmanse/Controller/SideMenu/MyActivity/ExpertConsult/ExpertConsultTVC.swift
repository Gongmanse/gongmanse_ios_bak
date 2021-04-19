import UIKit

class ExpertConsultTVC: UITableViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var consultTitleLabel = ["상담하기 제목이 들어가는 곳", "상담하기 제목이 2줄 이상인 경우 이런 식으로 표시", "상담하기 제목이 3줄 이상인 경우 이런 식으로 표시합니다."]
    var nickNameLabel = ["카모마일", "공스", "공스"]
    var upLoadDateLabel = ["1년 전", "2년 전", "3년 전"]
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultTVCell") as! ExpertConsultTVCell
        
        cell.consultTitle.text = consultTitleLabel[indexPath.row]
        cell.nickName.text = nickNameLabel[indexPath.row]
        cell.upLoadDate.text = upLoadDateLabel[indexPath.row]
        
        if indexPath.row == 0 {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
            cell.answerStatus.text = "대기중 >"
        } else {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.answerStatus.text = "답변 완료 >"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
