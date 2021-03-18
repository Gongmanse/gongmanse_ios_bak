import UIKit

class BookMarkTVC: UITableViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    
    var subjectsLabel = ["과학", "한문", "세계지리", "수학"]
    var videoTitleLabel = ["일정 성분비 법칙", "한자의 3요소", "동남 및 남부 아시아의 종교", "약수와 배수의 관계"]
    var teachersNameLabel = ["안종수 선생님", "채송아 선생님", "김민정 선생님", "남윤희 선생님"]
    
    var pageIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰 빈칸 숨기기
        tableView.tableFooterView = UIView()
        
        //총 개수 label text 지정
        countAll.text = "총 4개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: "4"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: "4"))
        
        self.countAll.attributedText = attributedString
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkTVCell") as! BookMarkTVCell
        
        cell.videoTitle.text = videoTitleLabel[indexPath.row]
        cell.subjects.text = subjectsLabel[indexPath.row]
        cell.teachersName.text = teachersNameLabel[indexPath.row]
        
        if indexPath.row == 0 {
            cell.subjects.backgroundColor = #colorLiteral(red: 0.4470588235, green: 0.2549019608, blue: 0.6431372549, alpha: 1)
        } else if indexPath.row == 1 {
            cell.subjects.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.3019607843, blue: 0.3921568627, alpha: 1)
        } else if indexPath.row == 2 {
            cell.subjects.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.3019607843, blue: 0.3921568627, alpha: 1)
        } else if indexPath.row == 3 {
            cell.subjects.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.2666666667, blue: 0.6196078431, alpha: 1)
        }

        return cell
    }
    
    //셀 push 로 넘겨주고 난 후 강조 표시 해제
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
