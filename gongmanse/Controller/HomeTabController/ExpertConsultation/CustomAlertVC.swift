import UIKit
import Photos
import PhotosUI

@available(iOS 14, *)
class CustomAlertVC: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitleView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var selectVideo: UIButton!
    
    var uploadImageView: ExpertConsultationFloatingVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertTitleView.layer.addBorder([.bottom], color: .mainOrange, width: 3.0)
        self.alertView.layer.cornerRadius = 13
        self.alertTitleView.layer.cornerRadius = 13
        
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    //사진 불러오기
    @IBAction func selectPhotoAction(_ sender: Any) {
//        let requiredAccessLevel: PHAccessLevel = .readWrite
//        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
//            switch authorizationStatus {
//            case .limited:
//                print("limited authorization granted")
//            case .authorized:
//                print("authorization granted")
//            default:
//                //FIXME: Implement handling for all authorizationStatus
//                print("Unimplemented")
//            }
//        }
//
//        let accessLevel: PHAccessLevel = .readWrite
//        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
//        switch authorizationStatus {
//        case .limited:
//            print("limited authorization granted")
//        default: //FIXME: Implement handling for all authorizationStatus values
//            print("Not implemented")
//        }
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 0
                configuration.filter = .any(of: [.images, .videos])
        
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func selectVideoAction(_ sender: Any) {
    }
}

@available(iOS 14, *)
extension CustomAlertVC: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    self.uploadImageView?.upLoadImage.image = image as? UIImage
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}
