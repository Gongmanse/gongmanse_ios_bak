import UIKit

class SeriesVC: UIViewController {

    @IBOutlet weak var mainHeaderView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainSubjectTitle: UILabel!
    @IBOutlet weak var mainTeacherName: UILabel!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var videoCount: UILabel!
    
    var seriesShow: SeriesModels?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromJson()
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/video/serieslist?series_id=32&offset=0&limit=60") {
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
                }

            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.seriesShow?.totalNum else { return }
        
        self.videoCount.text = "총 \(value)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: videoCount.text!, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])

        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoCount.text! as NSString).range(of: value))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoCount.text! as NSString).range(of: value))

        self.videoCount.attributedText = attributedString
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
        cell.teachersName.text = indexData.sTeacher
        
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
