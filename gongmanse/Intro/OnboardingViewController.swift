import UIKit


class OnboardingViewController: UIViewController {

    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var videoLectureLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontColorPartEdit()
        btnCornerRadius()
        fontChange()
    }
    
    func fontChange() {
        firstTitleLabel.font = UIFont.appEBFontWith(size: 22)
        videoLectureLabel.font = UIFont.appEBFontWith(size: 40)
        videoCountLabel.font = UIFont.appEBFontWith(size: 50)
        nextBtn.titleLabel?.font = UIFont.appBoldFontWith(size: 17)
    }
    
    func fontColorPartEdit() {
        let attributedString = NSMutableAttributedString(string: welcomeLabel.text!, attributes: [.font: UIFont.appBoldFontWith(size: 18), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.appBoldFontWith(size: 18), range: (welcomeLabel.text! as NSString).range(of: "공만세"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (welcomeLabel.text! as NSString).range(of: "공만세"))
        
        self.welcomeLabel.attributedText = attributedString
    }
    
    func btnCornerRadius() {
        nextBtn.layer.cornerRadius = 8
        nextBtn.layer.shadowColor = UIColor.gray.cgColor
        nextBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        nextBtn.layer.shadowRadius = 5
        nextBtn.layer.shadowOpacity = 0.3
    }

    @IBAction func nextButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
