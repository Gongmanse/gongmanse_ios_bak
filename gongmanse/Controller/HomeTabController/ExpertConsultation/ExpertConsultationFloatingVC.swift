import UIKit

class ExpertConsultationFloatingVC: UIViewController {

    @IBOutlet weak var upLoadImage: UIImageView!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var writeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSettings()
        uploadImageSettings()
        answerTextViewSettings()
        writeBtnSettings()
    }
    
    func navigationBarSettings() {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func uploadImageSettings() {
        //업로드 이미지 라운딩 처리 및 Border 추가
        upLoadImage.layer.cornerRadius = 13
        upLoadImage.layer.borderWidth = 2.0
        upLoadImage.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        upLoadImage.backgroundColor = .clear
    }
    
    func answerTextViewSettings() {
        //답변 텍스트 뷰 라운딩 처리 및 Border 추가
        answerTextView.layer.cornerRadius = 13
        answerTextView.layer.borderWidth = 2.0
        answerTextView.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        answerTextView.backgroundColor = .clear
    }
    
    func writeBtnSettings() {
        //작성하기 버튼 라운딩 처리
        writeBtn.layer.cornerRadius = 8
        writeBtn.layer.shadowColor = UIColor.gray.cgColor
        writeBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        writeBtn.layer.shadowRadius = 5
        writeBtn.layer.shadowOpacity = 0.3
    }
    
    @IBAction func writeBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addImageAndVideo(_ sender: Any) {
        if #available(iOS 14, *) {
            let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertVC
            alertVC.modalPresentationStyle = .overCurrentContext
            present(alertVC, animated: false, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
}
