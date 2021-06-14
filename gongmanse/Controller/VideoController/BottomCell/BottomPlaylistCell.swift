/*
 하단 Cell 중 "재생목록" 에 대한 UI를 담당하는 View입니다.
 */

import Foundation
import UIKit

protocol BottomPlaylistCellDelegate: AnyObject {
    func videoControllerPresentVideoControllerInBottomPlaylistCell(videoID: String)
    func videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: String)
}

class BottomPlaylistCell: UICollectionViewCell {
    
    // MARK: - Property
    
    // 자동재생 싱글톤 객체
    let autoplayDataManager = AutoplayDataManager.shared
    
    // "플레이리스트" 와 " n / m " Label을 담을 ContainerView
    private let topPlayListTitleContainerView = UIView()
    
    private let playlistTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "플레이리스트"
        label.font = UIFont.appBoldFontWith(size: 11)
        return label
    }()
    
    public let numberOFplaylistLabel: UILabel = {
        let label = UILabel()
        label.text = "1 / 28"
        label.font = UIFont.appBoldFontWith(size: 11)
        return label
    }()
    
    weak var delegate: BottomPlaylistCellDelegate?
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var playlist = PlayListModels(isMore: true, totalNum: "", seriesInfo: PlayListInfo.init(sTitle: "", sTeacher: "", sSubjectColor: "", sSubject: "", sGrade: ""), data: [PlayListData]())
    var isLoading = false
    
    var recommendSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var popularSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var koreanSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var scienceSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var socialStudiesSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    var otherSubjectsSeriesID: String = "" {
        didSet { getDataFromJson() }
    }
    
    // 추천
    // "RecommandVC" 에서 받아온 데이터
    var receiveRecommendModelData: VideoInput?
    
    //인기
    var receivePopularModelData: VideoInput?
    var popularViewTitleValue: String = ""
    
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
    var recieveOtherSubjectsModelData: VideoInput?
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
        tableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "BottomPlaylistTVCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BottomPlaylistTVCell")
        
        let tableViewLoadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "LoadingCell")
        
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = 81
        
        self.addSubview(topPlayListTitleContainerView)
        topPlayListTitleContainerView.translatesAutoresizingMaskIntoConstraints = false
        topPlayListTitleContainerView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            topPlayListTitleContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            topPlayListTitleContainerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            topPlayListTitleContainerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            topPlayListTitleContainerView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        topPlayListTitleContainerView.addSubview(playlistTitleLabel)
        topPlayListTitleContainerView.addSubview(numberOFplaylistLabel)
        
        playlistTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playlistTitleLabel.centerYAnchor.constraint(equalTo: topPlayListTitleContainerView.centerYAnchor),
            playlistTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            playlistTitleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        numberOFplaylistLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberOFplaylistLabel.centerYAnchor.constraint(equalTo: topPlayListTitleContainerView.centerYAnchor),
            numberOFplaylistLabel.leftAnchor.constraint(equalTo: playlistTitleLabel.rightAnchor, constant: 10),
            numberOFplaylistLabel.heightAnchor.constraint(equalTo: playlistTitleLabel.heightAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topPlayListTitleContainerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isUserInteractionEnabled = true
    }
    
    var default1 = 0
    
    func getDataFromJson() {
        if popularViewTitleValue == "인기HOT! 동영상 강의" {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(popularSeriesID)&offset=0") {
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
//                        self.numberOFplaylistLabel.text = self.playlist.totalNum

                    }
                    
                }.resume()
            }
        } else if koreanViewTitleValue == "국영수 강의" {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(koreanSeriesID)&offset=\(default1)") {
                default1 += 20
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else { return }
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(PlayListModels.self, from: data) {
                        //print(json.data)
                        //self.playlist = json
                        self.playlist.data.append(contentsOf: json.data)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.numberOFplaylistLabel.text = self.playlist.totalNum

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
                        self.numberOFplaylistLabel.text = self.playlist.totalNum

                    }
                    
                }.resume()
            }
        } else if socialStudiesViewTitleValue == "사회 강의" {
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
                        self.numberOFplaylistLabel.text = self.playlist.totalNum

                    }
                    
                }.resume()
            }
        } else if otherSubjectsViewTitleValue == "기타 강의" {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(otherSubjectsSeriesID)&offset=0") {
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
                        self.numberOFplaylistLabel.text = self.playlist.totalNum
                    }
                    
                }.resume()
            }
        } else {
            if let url = URL(string: apiBaseURL + "/v/video/serieslist?series_id=\(recommendSeriesID)&offset=0") {
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
                        self.numberOFplaylistLabel.text = self.playlist.totalNum

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
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.receiveKoreanModelData?.body else { return 0 }
                return autoPlayOffdata.count
            } else {
                if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
//                    if section == 0 {
//                        //guard let data = self.playlist?.data else { return 0 }
//                        let data = self.playlist.data
//                        return data.count
//                    } else if section == 1 {
//                        return 1
//                    } else {
//                        return 0
//                    }
                   // guard let data = self.playlist?.data else { return 0 }
                    let data = self.playlist.data
                    return data.count
                }
            }
        } else if scienceViewTitleValue == "과학 강의" {
            if scienceSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.recieveScienceModelData?.body else { return 0 }
                return autoPlayOffdata.count
            } else {
                if scienceSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
                    //guard let data = self.playlist.data else { return 0 }
                    let data = self.playlist.data
                    return data.count
                }
            }
        } else if socialStudiesViewTitleValue == "사회 강의" {
            if socialStudiesSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.recieveSocialStudiesModelData?.body else { return 0 }
                return autoPlayOffdata.count
            } else {
                if socialStudiesSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
                    //guard let data = self.playlist.data else { return 0 }
                    let data = self.playlist.data
                    return data.count
                }
            }
        } else if otherSubjectsViewTitleValue == "기타 강의" {
            if otherSubjectsSwitchOnOffValue.isOn {
                guard let autoPlayOffdata = self.recieveOtherSubjectsModelData?.body else { return 0 }
                return autoPlayOffdata.count
            } else {
                if otherSubjectsSelectedBtnValue.currentTitle == "문제 풀이" {
                    return 1
                } else {
                    //guard let data = self.playlist.data else { return 0 }
                    let data = self.playlist.data
                    return data.count
                }
            }
        } else {
            //guard let data = self.playlist.data else { return 0 }
            let data = self.playlist.data
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                
                guard let onJson = self.receiveKoreanModelData else { return cell }

                /* TEST - 자동재생 켰을 때, 재생목록 테스트중*/
                let mainSubjectBodyData = autoplayDataManager.videoDataInMainSubjectsTab?.body[indexPath.row]
//                let indexOnData = onJson.body[indexPath.row]
                let indexOnData = mainSubjectBodyData!
                
                let url = URL(string: makeStringKoreanEncoded(indexOnData.thumbnail ?? "nil"))
                cell.cellVideoID = indexOnData.videoId
                let videoDataManager = VideoDataManager.shared
                if cell.cellVideoID == videoDataManager.currentVideoID {
                    cell.highlightView.backgroundColor = .progressBackgroundColor
                } else {
                    cell.highlightView.backgroundColor = .clear
                }
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
                
                
            } else { // 자동재생 Off
                
                if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                    //                let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as! EmptyTableViewCell
                    cell.emptyLabel.text = "재생 목록이 없습니다."
                    tableView.isScrollEnabled = false
                    tableView.allowsSelection = false
//                    cell.selectionStyle = .none
                    return cell
                    
                // 시리즈보기
                } else {
                    
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
//                    let mainSubjectBodyData = autoplayDataManager.videoDataInMainSubjectsTab?.body[indexPath.row]
//    //                let indexOnData = onJson.body[indexPath.row]
//                    let indexOnData = mainSubjectBodyData!
                    
                    let indexOnData = playlist.data[indexPath.row]
                    
                    let url = URL(string: makeStringKoreanEncoded(indexOnData.sThumbnail ?? "nil"))
                    cell.cellVideoID = indexOnData.id
                    let videoDataManager = VideoDataManager.shared
                    if cell.cellVideoID == videoDataManager.currentVideoID {
                        cell.highlightView.backgroundColor = .progressBackgroundColor
                    } else {
                        cell.highlightView.backgroundColor = .clear
                    }
                    cell.videoThumbnail.sd_setImage(with: url)
                    cell.videoThumbnail.contentMode = .scaleAspectFill
                    cell.subjects.text = indexOnData.sSubject
                    cell.videoTitle.text = indexOnData.sTitle
                    cell.teachersName.text = (indexOnData.sTeacher ?? "nil") + " 선생님"
//                    cell.starRating.text = indexOnData.r
                    cell.subjects.backgroundColor = UIColor(hex: indexOnData.sSubjectColor ?? "nil")
                    
                    
                    return cell
                }
                
                if indexPath.section == 0 {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                    
                    //guard let json = self.playlist else { return cell }
                    let json = self.playlist
                    
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
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else { return UITableViewCell() }
                    
                        //cell.loadingIndicator.startAnimating()
                    
                    return cell
                }
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
//                    cell.selectionStyle = .none
                    return cell
                }
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                
                //guard let json = self.playlist else { return cell }
                let json = self.playlist
                
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
        } else if socialStudiesViewTitleValue == "사회 강의" {
            
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
//                    cell.selectionStyle = .none
                    return cell
                }
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                
                //guard let json = self.playlist else { return cell }
                let json = self.playlist
                
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
        } else if otherSubjectsViewTitleValue == "기타 강의" {
            
            if otherSubjectsSwitchOnOffValue.isOn {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                
                guard let onJson = self.recieveOtherSubjectsModelData else { return cell }
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
                
                if otherSubjectsSelectedBtnValue.currentTitle == "문제 풀이" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                    cell.emptyLabel.text = "재생 목록이 없습니다."
                    tableView.isScrollEnabled = false
                    tableView.allowsSelection = false
//                    cell.selectionStyle = .none
                    return cell
                }
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
                
                //guard let json = self.playlist else { return cell }
                let json = self.playlist
                
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
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomPlaylistTVCell", for: indexPath) as? BottomPlaylistTVCell else { return UITableViewCell() }
            
            //guard let json = self.playlist else { return cell }
            
            let json = self.playlist
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if koreanViewTitleValue == "국영수 강의" {
            if koreanSwitchOnOffValue.isOn {
                return 80
            } else {
                if koreanSelectedBtnValue.currentTitle == "전체 보기" {
                    if indexPath.section == 0 {
                        return 80
                    } else {
                        return 55
                    }
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
        } else if socialStudiesViewTitleValue == "사회 강의" {
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
        } else if otherSubjectsViewTitleValue == "기타 강의" {
            if otherSubjectsSwitchOnOffValue.isOn {
                return 80
            } else {
                if otherSubjectsSelectedBtnValue.currentTitle == "전체 보기" {
                    return 80
                } else if otherSubjectsSelectedBtnValue.currentTitle == "문제 풀이" {
                    return tableView.frame.height
                }
            }
            return 80
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // 06.14 이전에 작성된 코드
//        tableView.deselectRow(at: indexPath, animated: true)
//        let data = playlist
//        let videoID = data.data[indexPath.row].id
        
        
        // 06.14 이후 코드
        if koreanViewTitleValue == "국영수 강의" {
            
            // 변경해야한다면, 싱글톤으로 만든 Switch on/off : autoplayDataManager.isAutoplayMainSubject
            if koreanSwitchOnOffValue.isOn {
                
                if let videoID = autoplayDataManager.videoDataInMainSubjectsTab?.body[indexPath.row].videoId {
                    
                    // "VideoController" 에서 영상을 새롭게 실행시켜준다.
                    delegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: videoID)
                }
                
            // TODO: 시리즈보기
            } else {
                if koreanSelectedBtnValue.currentTitle == "전체 보기" {
                    // TODO: 국영수 > 전체보기 > 셀 클릭 -> Default
                } else if koreanSelectedBtnValue.currentTitle == "문제 풀이" {
                    
                    if let videoID = autoplayDataManager.videoDataInMainSubjectsProblemSolvingTab?.data[indexPath.row].id {
                        delegate?.videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: videoID)

                    }
                    // TODO: 국영수 > 문제풀이선택 > 셀 클릭
                }
                
            }
            
            
            // 일단 국어만
            
        } else if scienceViewTitleValue == "과학 강의" {
            if scienceSwitchOnOffValue.isOn {
                // TODO: 과학 > 전체보기 > 셀 클릭

            // TODO: 시리즈보기
            } else {
                
                if scienceSelectedBtnValue.currentTitle == "전체 보기" {
                    // TODO: 과학 > 전체보기 > 셀 클릭
                } else if scienceSelectedBtnValue.currentTitle == "문제 풀이" {
                    // TODO: 과학 > 문제풀이선택 > 셀 클릭
                }
            }
            
        } else if socialStudiesViewTitleValue == "사회 강의" {
            if socialStudiesSwitchOnOffValue.isOn {
                // TODO: 사회 > 전체보기 > 셀 클릭

                
            // TODO: 시리즈보기
            } else {
                if socialStudiesSelectedBtnValue.currentTitle == "전체 보기" {
                    // TODO: 사회 > 전체보기 > 셀 클릭
                } else if socialStudiesSelectedBtnValue.currentTitle == "문제 풀이" {
                    // TODO: 사회 > 문제풀이선택 > 셀 클릭
                }
            }
            
        } else if otherSubjectsViewTitleValue == "기타 강의" {
            if otherSubjectsSwitchOnOffValue.isOn {
                // TODO: 기타 > 전체보기 > 셀 클릭
            
                
            // TODO: 시리즈보기
            } else {
                if otherSubjectsSelectedBtnValue.currentTitle == "전체 보기" {
                    // TODO: 기타 > 전체보기 > 셀 클릭
                } else if otherSubjectsSelectedBtnValue.currentTitle == "문제 풀이" {
                    // TODO: 기타 > 문제풀이선택 > 셀 클릭
                }
            }
            
        } else {
            
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//
//        if (offsetY > contentHeight - scrollView.frame.height) && !isLoading {
//            getDataFromJson()
//            tableView.reloadData()
//            loadMoreData()
//        }
//    }
    
//    func loadMoreData() {
//        if !self.isLoading {
//            self.isLoading = true
//            DispatchQueue.global().async {
//                sleep(4)
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.isLoading = false
//                }
//            }
//        }
//    }
}
