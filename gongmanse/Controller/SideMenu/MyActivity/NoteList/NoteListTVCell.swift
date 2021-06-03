import UIKit

protocol NoteListTVCellDelegate: AnyObject {
    func indexPathPassVC(indexPath: Int)
}


class NoteListTVCell: UITableViewCell {
    
    weak var delegate: NoteListTVCellDelegate?
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var upLoadDate: UILabel!
    @IBOutlet weak var noteVideoPlayBtn: UIButton!
    
    var indexPathRow: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //subjects label text 지정
        subjects.text = "화학"

        if let index = self.indexPathRow {
            delegate?.indexPathPassVC(indexPath: index)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @objc func test() {
        print("성공")
    }
}
