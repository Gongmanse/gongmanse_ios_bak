import UIKit

class CustomAlertVC: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitleView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var selectVideo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.alertTitleView.layer.addBorder([.bottom], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
        self.alertView.layer.cornerRadius = 13
        self.alertTitleView.layer.cornerRadius = 13
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func selectPhotoAction(_ sender: Any) {
        
    }
    
    @IBAction func selectVideoAction(_ sender: Any) {
        
    }
}
