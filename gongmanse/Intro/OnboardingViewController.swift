import UIKit


class OnboardingViewController: UIViewController {

//    @IBOutlet weak var firstTitleLabel: UILabel!
//    @IBOutlet weak var videoLectureLabel: UILabel!
//    @IBOutlet weak var videoCountLabel: UILabel!
//    @IBOutlet weak var welcomeLabel: UILabel!
//    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControll: UIPageControl!
    let resArray:[String] = ["manual_0", "manual_1", "manual_2", "manual_3",
                             "manual_4", "manual_5", "manual_6", "manual_7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fontChange()
//        fontColorPartEdit()
        btnCornerRadius()
        
//        pageControll.numberOfPages = 8
//        pageControll.currentPage = 0
//        pageControll.isEnabled = false
    }
    
//    func fontChange() {
//        firstTitleLabel.font = UIFont.appEBFontWith(size: 22)
//        videoLectureLabel.font = UIFont.appEBFontWith(size: 40)
//        videoCountLabel.font = UIFont.appEBFontWith(size: 50)
//        nextBtn.titleLabel?.font = UIFont.appBoldFontWith(size: 17)
//    }
//
//    func fontColorPartEdit() {
//        let attributedString = NSMutableAttributedString(string: welcomeLabel.text!, attributes: [.font: UIFont.appBoldFontWith(size: 18), .foregroundColor: UIColor.black])
//
//        attributedString.addAttribute(.font, value: UIFont.appBoldFontWith(size: 18), range: (welcomeLabel.text! as NSString).range(of: "공만세"))
//        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (welcomeLabel.text! as NSString).range(of: "공만세"))
//
//        self.welcomeLabel.attributedText = attributedString
//    }
    
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
        present(vc, animated: true, completion: nil)
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingIntroCell", for: indexPath) as! OnboardingIntroCell
        
        cell.imageView.image = UIImage(named: resArray[indexPath.row])!
        
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.bounds.size.width)
        let currentPageNumber = Int(pageNumber) % resArray.count
        pageControll.currentPage = currentPageNumber
    }
}
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

