import UIKit

class NoteListTVCell: UITableViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var upLoadDate: UILabel!
    @IBOutlet weak var noteVideoPlayBtn: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var indexPathRow: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //deleteView 라운딩 처리
        deleteView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 13.0)
        deleteButton.roundCorners(corners: [.topLeft, .bottomLeft], radius: 13.0)
        deleteButton.setBackgroundColor(.lightGray.withAlphaComponent(0.7), for: .highlighted)
        
        //버튼, 버튼 뷰 숨김
        deleteView.isHidden = true
        deleteButton.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @objc func test() {
        print("성공")
    }
}
