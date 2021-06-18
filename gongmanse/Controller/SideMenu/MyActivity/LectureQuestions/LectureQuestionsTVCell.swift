import UIKit

class LectureQuestionsTVCell: UITableViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var upLoadDate: UILabel!
    @IBOutlet weak var answerStatus: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
        
        //답변 상태 label background 라운딩 처리
        answerStatus.layer.cornerRadius = 7
        answerStatus.clipsToBounds = true
        
        //deleteView 라운딩 처리
        deleteView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 13.0)
        
        //버튼, 버튼 뷰 숨김
        deleteView.isHidden = true
        deleteButton.isHidden = true
        upLoadDate.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
