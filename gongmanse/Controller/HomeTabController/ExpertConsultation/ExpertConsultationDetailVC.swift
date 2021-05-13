import UIKit

class ExpertConsultationDetailVC: UIViewController {

    @IBOutlet weak var profileAndDateView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNickName: UILabel!
    @IBOutlet weak var registerDate: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var consultContentView: UIView!
    @IBOutlet weak var consultImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var receiveData: ExpertModelData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviAndViewSettings()
        borderWithButton()
        
        //이미지들 라운딩 처리
        profileImageView.layer.cornerRadius = 13
        
        consultImageSettings()
        receiveDataSettings()
        
        //print(receiveData?.consultation_id)
        
    }
    
    func receiveDataSettings() {
        let profileImageURL = receiveData?.sProfile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        let defaultLink = fileBaseURL
        let thumbnailImageURL = receiveData?.sFilepaths ?? ""
        let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
        
        if profileImageURL == ""{
            profileImageView.image = UIImage(named: "extraSmallUserDefault")
        }else {
            profileImageView.sd_setImage(with: profileURL)
        }
        
        self.consultImageView.sd_setImage(with: thumbnailURL)
        self.profileNickName.text = receiveData?.sNickname
        self.registerDate.text = receiveData?.dtRegister
        self.questionLabel.text = receiveData?.sQuestion?.htmlEscaped
        
        if receiveData?.iAnswer == "0" {
            answerLabel.text = "답변을 기다리는 중입니다."
        } else {
            self.answerLabel.text = receiveData?.sAnswer?.htmlEscaped
        }
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
    
    func consultImageSettings() {
        //상담 이미지 파일 shadow 및 cornerRadius
        consultContentView.layer.cornerRadius = 13
        consultContentView.layer.shadowColor = UIColor.gray.cgColor
        consultContentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        consultContentView.layer.shadowRadius = 13
        consultContentView.layer.shadowOpacity = 0.7
        
        consultImageView.layer.cornerRadius = 13
        consultImageView.clipsToBounds = true
    }
}
