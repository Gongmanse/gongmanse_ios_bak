import UIKit

class PopularVC: UIViewController {
    
    var pageIndex: Int!
    
    var popularVideo = VideoInput(header: HeaderData.init(resultMsg: "", totalRows: "", isMore: ""), body: [VideoModels]())
    
    var popularVideoSecond: BeforeApiModels?
    
    let popularRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var popularCollection: UICollectionView!

    // 무한 스크롤 프로퍼티
    var gradeText: String = ""
    var listCount: Int = 0
    var isDataListMore: Bool = true
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Constant.token != "" {
            getDataFromJsonSecond(grade: gradeText, offset: listCount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popularCollection.refreshControl = popularRC
        
//        getDataFromJson()
        viewTitleSettings()
        
    }
    
    func viewTitleSettings() {
        viewTitle.text = "인기HOT! 동영상 강의"
        
        let attributedString = NSMutableAttributedString(string: viewTitle.text!, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (viewTitle.text! as NSString).range(of: "HOT!"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: (viewTitle.text! as NSString).range(of: "HOT!"))
        
        self.viewTitle.attributedText = attributedString
    }
    
    func getDataFromJson() {
        if let url = URL(string: makeStringKoreanEncoded(Popular_Video_URL + "/모든?offset=0&limit=30")) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //print(json.body)
                    self.popularVideo.body.append(contentsOf: json.body)
                }
                DispatchQueue.main.async {
                    self.popularCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    /// 1.0 인기리스트 API
    func getDataFromJsonSecond(grade: String, offset: Int) {
        guard let gradeEncoding = grade.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        if let url = URL(string: "\(apiBaseURL)/v/video/trendingvid?offset=\(offset)&limit=20&grade=\(gradeEncoding)") {
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"

            switch isDataListMore {
            
            case false:
                return
                
            case true:
                if offset == 0 {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(BeforeApiModels.self, from: data) {
                            self.popularVideoSecond = json
                        }
                        DispatchQueue.main.async {
                            self.popularCollection.reloadData()
                        }

                    }.resume()
                } else {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        
                        if let json = try? decoder.decode(BeforeApiModels.self, from: data) {
                            
                            if json.data.count == 0 {
                                self.isDataListMore = true
                                return
                            }
                            
                            for i in 0..<json.data.count {
                                self.popularVideoSecond?.data.append(json.data[i])
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.popularCollection.reloadData()
                        }

                    }.resume()
                }
            }
            
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        popularCollection.reloadData()
        sender.endRefreshing()
    }
}

extension PopularVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //guard let data = self.popularVideo?.data else { return 0}
//        let popularData = self.popularVideo
//        return popularData.body.count
        return popularVideoSecond?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCVCell", for: indexPath) as! PopularCVCell
        //guard let json = self.popularVideo else { return cell }
  
        // 2.0 API
//        let json = self.popularVideo
//        let indexData = json.body[indexPath.row]
        
        // 1.0 API
        let indexData = popularVideoSecond?.data[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded("\(fileBaseURL)/\(indexData?.sThumbnail ?? "")"))
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData?.sTitle
        cell.teachersName.text = (indexData?.sTeacher ?? "nil") + " 선생님"
        cell.subjects.text = indexData?.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData?.sSubjectColor ?? "nil")
        cell.starRating.text = indexData?.iRating

        if indexData?.sUnit != "" {
            cell.term.isHidden = false
            cell.term.text = indexData?.sUnit
        } else if indexData?.sUnit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData?.sUnit == "2" {
            cell.term.isHidden = false
            cell.term.text = "ii"
        } else {
            cell.term.isHidden = true
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PopularTitleCVCell", for: indexPath) as? PopularTitleCVCell else {
                return UICollectionReusableView()
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position == (popularCollection.contentSize.height - scrollView.frame.size.height) {
            // TODO: 로딩인디케이터
//            UIView.animate(withDuration: 3) {
//                // 로딩이미지
//            } completion: { (_) in
//                // API 호춣
//            }
//            getDataFromJson()
//            popularCollection.reloadData()
//            print("hshs")
//        }
//    }
}

extension PopularVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Constant.isLogin {
            let vc = VideoController()
            let videoDataManager = VideoDataManager.shared
            videoDataManager.isFirstPlayVideo = true
            vc.modalPresentationStyle = .fullScreen
            let videoID = popularVideo.body[indexPath.row].videoId
            vc.id = videoID
            let seriesID = popularVideoSecond?.data[indexPath.row].iSeriesId
            vc.popularSeriesId = seriesID
            vc.popularReceiveData = popularVideo
            vc.popularViewTitle = viewTitle.text
            
            let autoDataManager = AutoplayDataManager.shared
            autoDataManager.currentViewTitleView = "인기"
            
            present(vc, animated: true)
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = popularVideoSecond?.data.count  else { return }

        if indexPath.row == cellCount - 1 {
            
            listCount += 20
            print(listCount)
            getDataFromJsonSecond(grade: gradeText, offset: listCount)
            
        }
    }
    
}

extension PopularVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: 265)
    }
}
