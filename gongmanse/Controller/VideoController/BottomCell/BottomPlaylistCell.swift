/*
 하단 Cell 중 "재생목록" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

class BottomPlaylistCell: UICollectionViewCell {
    
    var playlist: PlayListModels?
    
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
        
//        getDataFromJson()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        
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
        if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=168&offset=0") {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
//        guard let data = self.playlist?.data else { return 0}
//        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
        
//        guard let json = self.playlist else { return cell }
//
//        let indexData = json.data[indexPath.row]
//        let url = URL(string: makeStringKoreanEncoded(indexData.sThumbnail))
//
//        cell.videoThumbnail.contentMode = .scaleAspectFill
//        cell.videoThumbnail.sd_setImage(with: url)
//        cell.videoTitle.text = indexData.sTitle
//        cell.teachersName.text = indexData.sTeacher + " 선생님"
//        cell.subjects.text = indexData.sSubject
//        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)
//
//        if indexData.sUnit == "" {
//            cell.term.isHidden = true
//        } else if indexData.sUnit == "1" {
//            cell.term.isHidden = false
//            cell.term.text = "i"
//        } else if indexData.sUnit == "2" {
//            cell.term.isHidden = false
//            cell.term.text = "ii"
//        }
        
        return cell
    }
}
