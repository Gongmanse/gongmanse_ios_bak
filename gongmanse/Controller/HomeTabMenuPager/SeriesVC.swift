import UIKit

class SeriesVC: UIViewController {

    @IBOutlet weak var mainHeaderView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainTeacherName: UILabel!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var videoCount: UILabel!
    
    @IBOutlet weak var subjectColor: UIStackView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        seriesCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    var seriesShow: SeriesModels?
    var receiveSeriesId: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromJson()
        mainFontAndRadiusSettings()
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    
    func mainFontAndRadiusSettings() {
        mainTeacherName.font = UIFont.appEBFontWith(size: 13)
    
    }
    
    func getDataFromJson() {
        if let url = URL(string: "\(apiBaseURL)/v/video/serieslist?series_id=\(receiveSeriesId ?? "")&offset=0&limit=60") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(SeriesModels.self, from: data) {
                    //print(json.body)
                    self.seriesShow = json
                }
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadData()
                    self.textSettings()
                    self.mainSettings()
                }

            }.resume()
        }
    }
    
    @IBAction func goToBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textSettings() {
        guard let value = self.seriesShow else { return }
        
        self.videoCount.text = "총 \(value.totalNum)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])

        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoCount.text! as NSString).range(of: value.totalNum))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoCount.text! as NSString).range(of: value.totalNum))

        self.videoCount.attributedText = attributedString
    }
    
    func mainSettings() {
        
        guard let teacherNames = seriesShow?.seriesInfo.sTeacher else { return }

        
        mainTitle.text = seriesShow?.seriesInfo.sTitle
        mainTeacherName.text = teacherNames + " 선생님"
        
        let headerData = seriesShow?.seriesInfo
        
        if headerData?.sGrade == "초등" {
            gradeLabel.text = "초"
        }else if headerData?.sGrade == "중등" {
            gradeLabel.text = "중"
        }else if headerData?.sGrade == "고등" {
            gradeLabel.text = "고"
        }
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 12)
        subjectLabel.textColor = .white
        subjectLabel.text = headerData?.sSubject
        
        // gradeLabel
        gradeLabel.textColor = UIColor(hex: headerData?.sSubjectColor ?? "")
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 12)
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 8
        
        
        // subjectColor
        subjectColor.backgroundColor = UIColor(hex: headerData?.sSubjectColor ?? "")
        subjectColor.layer.cornerRadius = subjectColor.frame.size.height / 2
        subjectColor.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        subjectColor.isLayoutMarginsRelativeArrangement = true
    }
}

extension SeriesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.seriesShow?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCollectionViewCell", for: indexPath) as? SeriesCollectionViewCell else { return UICollectionViewCell() }
        
        guard let json = self.seriesShow else { return cell }
        
        let indexData = json.data[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(fileBaseURL + "/" + indexData.sThumbnail))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)
        cell.teachersName.text = indexData.sTeacher + " 선생님"
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        AutoplayDataManager.shared.isAutoPlay = false
        AutoplayDataManager.shared.currentIndex = -1
        AutoplayDataManager.shared.videoDataList.removeAll()
        AutoplayDataManager.shared.videoSeriesDataList.removeAll()
        
        let vc = VideoController()
        vc.modalPresentationStyle = .overFullScreen
        let videoID = seriesShow?.data[indexPath.row].id
        vc.id = videoID
        present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
    }
}

extension SeriesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: (width / 16 * 9 + 70))
    }
}
