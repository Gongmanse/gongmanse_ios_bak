/*
 하단 Cell 중 "재생목록" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

protocol BottomPlaylistCellDelegate: AnyObject {
    func videoControllerPresentVideoControllerInBottomPlaylistCell(videoID: String)
}

class BottomPlaylistCell: UICollectionViewCell {
    
    weak var delegate: BottomPlaylistCellDelegate?
    
    var playlist: PlayListModels?
    var videoID: String = ""
    
//    var label: UILabel = {
//        let label = UILabel()
//        label.text = "재생목록2"
//        label.textColor = .black
//        label.textAlignment = .center
//        label.font = UIFont.appBoldFontWith(size: 40)
//        return label
//    }()
    
    private let tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()

    
    //MARK: - Lifecycle
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//       // initialize what is needed
//        self.addSubview(label)
//        self.backgroundColor = .white
//        label.centerX(inView: self)
//        label.centerY(inView: self)
//    }
 
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//
//        self.isUserInteractionEnabled = true
//       // initialize what is needed
//    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        
        getDataFromJson()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "BottomPlaylistTVCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BottomPlaylistTVCell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = 81
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.isUserInteractionEnabled = true
    }
    
    func getDataFromJson() {
        if let url = URL(string: apiBaseURL + "/v/video/relatives?video_id=1") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(PlayListModels.self, from: data) {
                    print(json.data)
                    self.playlist = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }.resume()
        }
    }
    
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}

extension BottomPlaylistCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        guard let data = self.playlist?.data else { return 0}
        return data.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
        
        guard let json = self.playlist else { return cell }

        let indexData = json.data[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(fileBaseURL + "/" + indexData.sThumbnail))

        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.teachersName.text = indexData.sTeacher + " 선생님"
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)

        if indexData.sUnit == "" {
            cell.term.isHidden = true
        } else if indexData.sUnit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData.sUnit == "2" {
            cell.term.isHidden = false
            cell.term.text = "ii"
        } else {
            cell.term.isHidden = false
            cell.term.text = indexData.sUnit
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let data = playlist {
            let videoID = data.data[indexPath.row].id
            delegate?.videoControllerPresentVideoControllerInBottomPlaylistCell(videoID: videoID)
        }
        
    }
}
