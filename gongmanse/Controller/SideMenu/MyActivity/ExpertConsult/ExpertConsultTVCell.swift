import UIKit

class ExpertConsultTVCell: UITableViewCell {
    
    @IBOutlet weak var consultThumbnail: UIImageView!
    @IBOutlet weak var consultTitle: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var upLoadDate: UILabel!
    @IBOutlet weak var answerStatus: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //상담 이미지 라운딩 처리
        consultThumbnail.layer.cornerRadius = 13
        //프로필 이미지 라운딩 처리
        profileImage.layer.cornerRadius = 13
        //답변 상태 label background 라운딩 처리
        answerStatus.layer.cornerRadius = 7
        answerStatus.clipsToBounds = true
        
        //deleteView 라운딩 처리
        deleteView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 13.0)
        deleteButton.roundCorners(corners: [.topLeft, .bottomLeft], radius: 13.0)
        deleteButton.setBackgroundColor(.lightGray.withAlphaComponent(0.7), for: .highlighted)
        
        //버튼, 버튼 뷰 숨김
        deleteView.isHidden = true
        deleteButton.isHidden = true
        upLoadDate.isHidden = true
        
        // 삭제 버튼 체크박스로 변경
        deleteButton.isSelected = false
        deleteButton.setImage(UIImage(named: "checkTrue"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
