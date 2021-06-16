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
    // Data
    var cellVideoID: String?
    var viewModel: VideoPlaylistVCViewModel? {
        didSet { updateUI() }
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

    }
    
    func updateUI() {
        
        guard let viewModel = self.viewModel else { return }
        guard let index = self.row else { return }
        let receivedData = viewModel.videoData.data
        self.videoTitle.text = receivedData[index].sTitle
        self.teachersName.text = receivedData[index].sTeacher
        self.subjects.text = receivedData[index].sSubject
        self.term.text = receivedData[index].sUnit
        self.term.isHidden = receivedData[index].sUnit.count < 2 ? true : false
        let urlString = makeStringKoreanEncoded(fileBaseURL + "/" + receivedData[index].sThumbnail)
        let url = URL(string: urlString)
        self.videoThumbnail.sd_setImage(with: url, completed: {_,_,_,_ in
            self.videoThumbnail.contentMode = .scaleAspectFill
        })
    }
}


// MARK: - 한글인코딩

extension BottomPlaylistTVCell {
    /// 한글 인코딩 처리 메소드
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}


