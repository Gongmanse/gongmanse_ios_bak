import UIKit

class KoreanEnglishMathAllSeriesCell: UICollectionViewCell {

    @IBOutlet weak var basicView: UIView!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var videoCountBackgroundView: UIView!
    @IBOutlet weak var seriesVideoCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        videoThumbnail.clipsToBounds = true
        
//        videoCountBackgroundView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 13.0)
        videoCountBackgroundView.layer.masksToBounds = true
        videoCountBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        videoCountBackgroundView.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        subjects.textColor = .white
    }

}
