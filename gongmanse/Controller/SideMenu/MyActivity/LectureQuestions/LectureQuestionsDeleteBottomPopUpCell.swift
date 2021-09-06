import UIKit

class LectureQuestionsDeleteBottomPopUpCell: UITableViewCell {

    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var deleteContext: UILabel!
    @IBOutlet weak var answerStatus: UILabel!
    @IBOutlet weak var timeBefore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //답변 상태 label background 라운딩 처리
        answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        answerStatus.textColor = .white
        answerStatus.layer.cornerRadius = 7
        answerStatus.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
