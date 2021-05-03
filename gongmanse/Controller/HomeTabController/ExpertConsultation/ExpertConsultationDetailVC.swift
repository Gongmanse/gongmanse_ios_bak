import UIKit

class ExpertConsultationDetailVC: UIViewController {

    @IBOutlet weak var profileAndDateView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNickName: UILabel!
    @IBOutlet weak var Date: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var consultImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviAndViewSettings()
        borderWithButton()
        
        //이미지들 라운딩 처리
        profileImageView.layer.cornerRadius = 13
        consultImageView.layer.cornerRadius = 13
    }
    
    //네비게이션 바와 프로필 뷰 설정
    func naviAndViewSettings () {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""

        profileAndDateView.layer.addBorder([.bottom], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
    }
    
    
    //버튼 밑줄 만들기
    func borderWithButton() {
        let editAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.black,
            .underlineStyle:NSUnderlineStyle.single.rawValue
        ]
        
        let deleteAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.red,
            .underlineStyle:NSUnderlineStyle.single.rawValue
        ]
        
        let editAttributesString = NSMutableAttributedString(string: "수정", attributes: editAttributes)
        editButton.setAttributedTitle(editAttributesString, for: .normal)
        
        let deleteAttributesString = NSMutableAttributedString(string: "삭제", attributes: deleteAttributes)
        deleteButton.setAttributedTitle(deleteAttributesString, for: .normal)
    }
}
