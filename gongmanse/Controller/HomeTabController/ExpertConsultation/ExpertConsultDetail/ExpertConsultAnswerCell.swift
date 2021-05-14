import UIKit

class ExpertConsultAnswerCell: UICollectionViewCell {
    
    @IBOutlet weak var answerLabel: UILabel!
    
    var receiveData: ExpertModelData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiveDataSettings()
    }
    
    func receiveDataSettings() {
        if receiveData?.iAnswer == "0" {
            answerLabel.text = "답변을 기다리는 중입니다."
        } else {
            self.answerLabel.text = receiveData?.sAnswer?.htmlEscaped
        }
    }
}
