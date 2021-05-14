import UIKit

class ExpertConsultReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileAndDateView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNickName: UILabel!
    @IBOutlet weak var registerDate: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var receiveData: ExpertModelData?
    var images = [UIImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //이미지들 라운딩 처리
        profileImageView.layer.cornerRadius = 13
        
        profileAndDateView.layer.addBorder([.bottom], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
        
        
    }
    
    func receiveDataSettings() {
        let profileImageURL = receiveData?.sProfile ?? ""
        let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
        
        self.profileNickName.text = receiveData?.sNickname
        self.profileImageView.sd_setImage(with: profileURL)
        self.registerDate.text = receiveData?.dtRegister
        self.questionLabel.text = receiveData?.sQuestion?.htmlEscaped
    }
}

extension ExpertConsultReusableView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receiveData?.sFilepaths?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
