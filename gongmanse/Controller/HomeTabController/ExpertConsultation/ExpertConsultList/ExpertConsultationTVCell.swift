import UIKit

class ExpertConsultationTVCell: UITableViewCell {

    @IBOutlet weak var consultThumbnail: UIImageView!
    @IBOutlet weak var consultTitle: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var answerStatus: UILabel!
    @IBOutlet weak var upLoadDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //상담 이미지 라운딩 처리
        consultThumbnail.layer.cornerRadius = 13
        //프로필 이미지 라운딩 처리
        profileImage.layer.cornerRadius = 13
        
        //답변 상태 label background 라운딩 처리
        answerStatus.layer.cornerRadius = 7
        answerStatus.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
