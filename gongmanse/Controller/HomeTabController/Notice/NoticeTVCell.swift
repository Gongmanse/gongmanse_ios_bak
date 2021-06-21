import UIKit

class NoticeTVCell: UITableViewCell {
    
    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var noticeDate: UILabel!
    @IBOutlet weak var noticeTime: UILabel!
    @IBOutlet weak var noticeBigTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
