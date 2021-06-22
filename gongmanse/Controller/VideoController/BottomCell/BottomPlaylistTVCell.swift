//
//  BottomPlaylistTVCell.swift
//  gongmanse
//
//  Created by 김현수 on 2021/05/17.
//
import SDWebImage
import UIKit

class BottomPlaylistTVCell: UITableViewCell {

    // MARK: - Property
    
    let autoPlayDataManager = AutoplayDataManager.shared
    
    // Data
    var cellVideoID: String?
    var viewModel: VideoPlaylistVCViewModel? {
        didSet {
//            updateUI()
        }
    }
    
    var cellData: PlayListData? {
        didSet {
            updateUI()
        }
    }
    
    var autoPlayData: VideoModels? {
        didSet {
            updateUI()
        }
    }
    var row: Int?

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var subjects: PaddingLabel!
    @IBOutlet weak var term: PaddingLabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var starRating: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
    
    // MARK: - Lifecycle
    
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
        
        // 안드로이드에 평점이 없으므로 UI변경 06.11
        starRating.alpha = 0
        
        highlightView.layer.cornerRadius = 7.5
        highlightView.backgroundColor = .clear
        videoThumbnail.contentMode = .scaleAspectFill
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

    }
    
    func updateUI() {

        if let cellData = self.cellData {
            self.videoTitle.text = cellData.sTitle
            self.teachersName.text = cellData.sTeacher
            self.subjects.text = cellData.sSubject
            self.term.text = cellData.sUnit
            self.term.isHidden = cellData.sUnit.count < 2 ? true : false
            let urlString = makeStringKoreanEncoded(fileBaseURL + "/" + cellData.sThumbnail)
            let url = URL(string: urlString)
            self.videoThumbnail.sd_setImage(with: url, completed: nil)
        }
        
        if let autoPlayData = self.autoPlayData {
            
            self.videoTitle.text = autoPlayData.title ?? ""
            self.teachersName.text = autoPlayData.teacherName
            self.subjects.text = autoPlayData.subject
            self.term.text = autoPlayData.unit
            
            if let unit = autoPlayData.unit {
                self.term.isHidden = unit.count < 2 ? true : false
            }
            
            
            if autoPlayDataManager.isAutoplaySearchTab {
                let urlString = makeStringKoreanEncoded((autoPlayData.thumbnail ?? ""))
                let url = URL(string: "\(fileBaseURL)/" + urlString)
                self.videoThumbnail.sd_setImage(with: url, completed: nil)
                return
            }
            
            let urlString = makeStringKoreanEncoded((autoPlayData.thumbnail ?? ""))
            let url = URL(string: urlString)
            
            self.videoThumbnail.sd_setImage(with: url, completed: nil)
            
        }
        

        
    }
}


// MARK: - 한글인코딩

extension BottomPlaylistTVCell {
    /// 한글 인코딩 처리 메소드
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}


