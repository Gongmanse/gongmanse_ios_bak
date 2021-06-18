import UIKit

class KoreanEnglishMathCVCell: UICollectionViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var starRating: UILabel!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cvcellSettings()
    }
    
    func cvcellSettings() {
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
    }
}
