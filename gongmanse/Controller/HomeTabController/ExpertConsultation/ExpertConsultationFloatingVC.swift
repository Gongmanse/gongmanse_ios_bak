import UIKit

class ExpertConsultationFloatingVC: UIViewController {
    
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var uploadImageCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSettings()
        answerTextViewSettings()
        writeBtnSettings()
        
        pageView.numberOfPages = 3
        pageView.currentPage = 0
        pageView.isEnabled = false
    }
    
    func navigationBarSettings() {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
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
        let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertVC
        alertVC.modalPresentationStyle = .overCurrentContext
        present(alertVC, animated: false, completion: nil)
    }
}

extension ExpertConsultationFloatingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConsultUploadImageCVCell", for: indexPath) as! ConsultUploadImageCVCell
        
        cell.deleteImage.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        return cell
    }
    
    @objc func deleteAction() {
        let alert = UIAlertController(title: "준비중입니다.", message: "빠른 시일내에 완성하도록 하겠습니다.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func updatePageControl(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.bounds.size.width)
        let count = 3
        let currentPageNumber = Int(pageNumber) % count
        pageView.currentPage = currentPageNumber
    }
}

extension ExpertConsultationFloatingVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = uploadImageCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
