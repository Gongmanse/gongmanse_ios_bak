import UIKit

class ExpertConsultationVC: UIViewController {

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var ExpertConsultationTV: UITableView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    
    var consultTitleLabel = ["상담하기 제목이 들어가는 곳", "상담하기 제목이 2줄 이상인 경우 이런 식으로 표시", "상담하기 제목이 3줄 이상인 경우 이런 식으로 표시합니다."]
    var nickNameLabel = ["카모마일", "공스", "공스"]
    var upLoadDateLabel = ["1년 전", "2년 전", "3년 전"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        //테이블 뷰 빈칸 숨기기
        ExpertConsultationTV.tableFooterView = UIView()
        
        //총 개수 label text 지정
        countAll.text = "총 3개"
        
        //상담하기 썸네일 총 개수 label 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: "3"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: "3"))
        
        self.countAll.attributedText = attributedString
        
        floatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    //플로팅 버튼 생성 및 크기 지정 후 뷰 이동
    func floatingButton() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 320, y: 695, width: 68, height: 68)
        btn.setImage(UIImage(named: "floatingBtn"), for: .normal)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func buttonTapped() {
        let floatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationFloatingVC") as! ExpertConsultationFloatingVC
        self.navigationController?.pushViewController(floatingVC, animated: true)
    }
}

extension ExpertConsultationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultationTVCell") as! ExpertConsultationTVCell
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
