import UIKit
import Photos

class CustomAlertVC: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitleView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var selectVideo: UIButton!
    
    var uploadImageView: ConsultUploadImageCVCell?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertTitleView.layer.addBorder([.bottom], color: .mainOrange, width: 3.0)
        self.alertView.layer.cornerRadius = 13
        self.alertTitleView.layer.cornerRadius = 13
        
        imagePicker.delegate = self
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    //사진 불러오기
    @IBAction func selectPhotoAction(_ sender: Any) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            //허용된 상태
            self.imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else if status == .denied {
            //허용 안한 상태
            setAuthAlertAction()
        } else if status == .restricted {
            //제한됨
        } else if status == .notDetermined {
            //결정 안됨 (아래와 같이 시스템 팝업 띄움)
            PHPhotoLibrary.requestAuthorization({ (result: PHAuthorizationStatus) in
                switch result {
                case .authorized:
                    break
                case .denied:
                    break
                default:
                    break
                }
            })
        }
    }
    
    func setAuthAlertAction() {
        let authAlert = UIAlertController(title: "사진첩 권한 요청", message: "사진첩 권한을 허용해야만 앨범을 사용하실 수 있습니다.", preferredStyle: .alert)
        let cancelAlertAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        let allowAlertAction = UIAlertAction(title: "확인", style: .default, handler: { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        authAlert.addAction(cancelAlertAction)
        authAlert.addAction(allowAlertAction)
        self.present(authAlert, animated: true, completion: nil)
    }
    
    @IBAction func selectVideoAction(_ sender: Any) {
    }
}


extension CustomAlertVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadImageView?.uploadImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}
