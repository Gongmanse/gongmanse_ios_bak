import UIKit

class ExpertConsultationDetailVC: UIViewController {
    
    @IBOutlet weak var expertConsultDetailScrollView: UIScrollView!
    @IBOutlet weak var expertConsultDisplayView: UIView!
    @IBOutlet weak var expertConsultDetailHeaderView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var registerDate: UILabel!
    
    @IBOutlet weak var imageSliderCollectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var receiveData: ExpertModelData?
    var receiveImageData: ExpertConsultImageData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviAndViewSettings()
        receiveDataSettings()
        
        profileImageView.layer.cornerRadius = 13
        
    }
    
    //네비게이션 바와 프로필 뷰 설정
    func naviAndViewSettings () {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        expertConsultDetailHeaderView.layer.addBorder([.bottom], color: .mainOrange, width: 3.0)
    }
    
    func receiveDataSettings() {
        let profileImageURL = receiveData?.sProfile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        
        if profileImageURL == "" {
            profileImageView.image = UIImage(named: "extraSmallUserDefault")
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
        
        self.nickName.text = receiveData?.sNickname
        self.registerDate.text = receiveData?.dtRegister
        self.questionLabel.text = receiveData?.sQuestion?.htmlEscaped
        
        if receiveData?.iAnswer == "0" {
            answerLabel.text = "답변을 기다리는 중입니다."
        } else {
            self.answerLabel.text = receiveData?.sAnswer?.htmlEscaped
        }
    }
}

extension ExpertConsultationDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSliderCollectionViewCell", for: indexPath) as? ImageSliderCollectionViewCell else { return UICollectionViewCell() }
        
        let defaultLink = fileBaseURL
        let thumbnailImageURL = receiveData?.sFilepaths ?? ""
        let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
        
        if receiveData?.sFilepaths != nil {
            cell.consultImageView.sd_setImage(with: thumbnailURL)
        } else {
            cell.consultImageView.image = UIImage(named: "photoDefault")
        }
        return cell
    }
}

extension ExpertConsultationDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 334, height: 150)
    }
}
