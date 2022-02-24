import UIKit

class SeriesCollectionViewCell: AutoPlayVideoCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    
    @IBOutlet weak var videoContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiSettings()
        fontSettings()
    }
    
    func uiSettings() {
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 8
        subjects.clipsToBounds = true
        subjects.textColor = .white
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
        term.textColor = .white
        
        videoAreaView = videoContainer
    }
    
    func fontSettings() {
        videoTitle.font = UIFont.appBoldFontWith(size: 19)
        subjects.font = UIFont.appBoldFontWith(size: 13)
        term.font = UIFont.appBoldFontWith(size: 13)
        teachersName.font = UIFont.appEBFontWith(size: 13)
    }
}
