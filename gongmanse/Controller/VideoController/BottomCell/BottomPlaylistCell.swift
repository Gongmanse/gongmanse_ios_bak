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
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var playlist: PlayListModels?
    var koreanSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var scienceSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var socialStudiesSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    //국영수
    var receiveKoreanModelData: VideoInput?
    var koreanSwitchOnOffValue: UISwitch!
    var koreanSelectedBtnValue: UIButton!
    var koreanViewTitleValue: String = ""
    
    //과학
    var recieveScienceModelData: VideoInput?
    var scienceSwitchOnOffValue: UISwitch!
    var scienceSelectedBtnValue: UIButton!
    var scienceViewTitleValue: String = ""
    
    //사회
    var recieveSocialStudiesModelData: VideoInput?
    var socialStudiesSwitchOnOffValue: UISwitch!
    var socialStudiesSelectedBtnValue: UIButton!
    var socialStudiesViewTitleValue: String = ""
    
    //기타
    var recieveOtherSubjectdsModelData: VideoInput?
    var otherSubjectsSwitchOnOffValue: UISwitch!
    var otherSubjectsSelectedBtnValue: UIButton!
    var otherSubjectsViewTitleValue: String = ""
    
    private let tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()

    
    //MARK: - Lifecycle
     
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        
        getDataFromJson()
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "BottomPlaylistTVCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BottomPlaylistTVCell")
        
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
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
        if koreanViewTitleValue == "국영수 강의" {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(koreanSeriesID)&offset=0") {
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(PlayListModels.self, from: data) {
                        //print(json.data)
                        self.playlist = json
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }.resume()
            }
        } else if scienceViewTitleValue == "과학 강의" {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(scienceSeriesID)&offset=0") {
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(PlayListModels.self, from: data) {
                        //print(json.data)
                        self.playlist = json
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }.resume()
            }
        } else {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(socialStudiesSeriesID)&offset=0") {
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(PlayListModels.self, from: data) {
                        //print(json.data)
                        self.playlist = json
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }.resume()
            }
        }
    }
    
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}

extension BottomPlaylistCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.receiveKoreanModelData?.body else { return 0}
                return autoPlayOffdata.count
            } else {
                if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
                    guard let data = self.playlist?.data else { return 0}
                    return data.count
                }
            }
        } else if scienceViewTitleValue == "과학 강의" {
            if scienceSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.recieveScienceModelData?.body else { return 0}
                return autoPlayOffdata.count
            } else {
                if scienceSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
                    guard let data = self.playlist?.data else { return 0}
                    return data.count
                }
            }
        } else {
//            if socialStudiesSwitchOnOffValue.isOn {
//                guard let autoPlayOffdata = self.recieveSocialStudiesModelData?.body else { return 0}
//                return autoPlayOffdata.count
//            } else {
//                if socialStudiesSelectedBtnValue.currentTitle == "문제 풀이" {
//                    return 1
//                } else {
//                    guard let data = self.playlist?.data else { return 0}
//                    return data.count
//                }
//            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
            
                guard let onJson = self.receiveKoreanModelData else { return cell }
                let indexOnData = onJson.body[indexPath.row]
                let url = URL(string: makeStringKoreanEncoded(indexOnData.thumbnail ?? "nil"))
                cell.videoThumbnail.sd_setImage(with: url)
                cell.videoThumbnail.contentMode = .scaleAspectFill
                
                cell.subjects.text = indexOnData.subject
                cell.videoTitle.text = indexOnData.title
                cell.teachersName.text = (indexOnData.teacherName ?? "nil") + " 선생님"
                cell.starRating.text = indexOnData.rating
                cell.subjects.backgroundColor = UIColor(hex: indexOnData.subjectColor ?? "nil")
                
                if indexOnData.unit != nil {
                    cell.term.isHidden = false
                    cell.term.text = indexOnData.unit
                } else if indexOnData.unit == "1" {
                    cell.term.isHidden = false
                    cell.term.text = "i"
                } else if indexOnData.unit == "2" {
                    cell.term.isHidden = false
                    cell.term.text = "ii"
                } else {
                    cell.term.isHidden = true
                }
                
                return cell
                
            } else {
                
                if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
    //                let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as! EmptyTableViewCell
                    cell.emptyLabel.text = "재생 목록이 없습니다."
                    tableView.isScrollEnabled = false
                    tableView.allowsSelection = false
                    cell.selectionStyle = .none
                    return cell
                }
                
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
            
        } else if scienceViewTitleValue == "과학 강의" {
            if scienceSwitchOnOffValue.isOn {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
            
                guard let onJson = self.recieveScienceModelData else { return cell }
                let indexOnData = onJson.body[indexPath.row]
                let url = URL(string: makeStringKoreanEncoded(indexOnData.thumbnail ?? "nil"))
                cell.videoThumbnail.sd_setImage(with: url)
                cell.videoThumbnail.contentMode = .scaleAspectFill
                
                cell.subjects.text = indexOnData.subject
                cell.videoTitle.text = indexOnData.title
                cell.teachersName.text = (indexOnData.teacherName ?? "nil") + " 선생님"
                cell.starRating.text = indexOnData.rating
                cell.subjects.backgroundColor = UIColor(hex: indexOnData.subjectColor ?? "nil")
                
                if indexOnData.unit != nil {
                    cell.term.isHidden = false
                    cell.term.text = indexOnData.unit
                } else if indexOnData.unit == "1" {
                    cell.term.isHidden = false
                    cell.term.text = "i"
                } else if indexOnData.unit == "2" {
                    cell.term.isHidden = false
                    cell.term.text = "ii"
                } else {
                    cell.term.isHidden = true
                }
                
                return cell
                
            } else {
                
                if scienceSelectedBtnValue.currentTitle == "문제 풀이" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                    cell.emptyLabel.text = "재생 목록이 없습니다."
                    tableView.isScrollEnabled = false
                    tableView.allowsSelection = false
                    cell.selectionStyle = .none
                    return cell
                }
                
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
        } else {
            
            if socialStudiesSwitchOnOffValue.isOn {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
            
                guard let onJson = self.recieveSocialStudiesModelData else { return cell }
                let indexOnData = onJson.body[indexPath.row]
                let url = URL(string: makeStringKoreanEncoded(indexOnData.thumbnail ?? "nil"))
                cell.videoThumbnail.sd_setImage(with: url)
                cell.videoThumbnail.contentMode = .scaleAspectFill
                
                cell.subjects.text = indexOnData.subject
                cell.videoTitle.text = indexOnData.title
                cell.teachersName.text = (indexOnData.teacherName ?? "nil") + " 선생님"
                cell.starRating.text = indexOnData.rating
                cell.subjects.backgroundColor = UIColor(hex: indexOnData.subjectColor ?? "nil")
                
                if indexOnData.unit != nil {
                    cell.term.isHidden = false
                    cell.term.text = indexOnData.unit
                } else if indexOnData.unit == "1" {
                    cell.term.isHidden = false
                    cell.term.text = "i"
                } else if indexOnData.unit == "2" {
                    cell.term.isHidden = false
                    cell.term.text = "ii"
                } else {
                    cell.term.isHidden = true
                }
                
                return cell
                
            } else {
                
                if socialStudiesSelectedBtnValue.currentTitle == "문제 풀이" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                    cell.emptyLabel.text = "재생 목록이 없습니다."
                    tableView.isScrollEnabled = false
                    tableView.allowsSelection = false
                    cell.selectionStyle = .none
                    return cell
                }
                
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
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                return 80
            } else {
                if koreanSelectedBtnValue.currentTitle == "전체 보기" {
                    return 80
                } else if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    return tableView.frame.height
                }
            }
            return 80
        } else if scienceViewTitleValue == "과학 강의" {
            if scienceSwitchOnOffValue.isOn {
                return 80
            } else {
                if scienceSelectedBtnValue.currentTitle == "전체 보기" {
                    return 80
                } else if scienceSelectedBtnValue.currentTitle == "문제 풀이" {
                    return tableView.frame.height
                }
            }
            return 80
        } else {
            if socialStudiesSwitchOnOffValue.isOn {
                return 80
            } else {
                if socialStudiesSelectedBtnValue.currentTitle == "전체 보기" {
                    return 80
                } else if socialStudiesSelectedBtnValue.currentTitle == "문제 풀이" {
                    return tableView.frame.height
                }
            }
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let data = playlist {
            let videoID = data.data[indexPath.row].id
            delegate?.videoControllerPresentVideoControllerInBottomPlaylistCell(videoID: videoID)
        }
        
    }
}
