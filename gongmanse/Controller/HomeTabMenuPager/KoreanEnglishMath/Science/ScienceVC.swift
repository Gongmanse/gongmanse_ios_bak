import UIKit

class ScienceVC: UIViewController {
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var videoTotalCount: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var scienceCollection: UICollectionView!
    
    var pageIndex: Int!
    
    var scienceVideo: ScienceVideoInput?
    
    //collectionView 새로고침
    let scienceRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        scienceCollection.refreshControl = scienceRC
        
        getDataFromJson()
        objectSettings()
        
    }
    
    func objectSettings() {
        //label에 지정된 text 넣기
        viewTitle.text = "과학 강의"
        videoTotalCount.text = "총 12,241개"
        
        //전체보기 버튼 Border 와 Corner Radius 적용
        selectBtn.layer.cornerRadius = 9
        //전체보기 버튼 Border width 적용
        selectBtn.layer.borderWidth = 2
        //전체보기 버튼 Border 색상 적용
        selectBtn.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(
            string: videoTotalCount.text!,
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: (videoTotalCount.text! as NSString).range(of: "12,241"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (videoTotalCount.text! as NSString).range(of: "12,241"))
        
        self.videoTotalCount.attributedText = attributedString
        
        //스위치 버튼 크기 줄이기
        playSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
    }
    
    //collectionView 새로고침 objc
    @objc private func refresh(sender: UIRefreshControl) {
        scienceCollection.reloadData()
        sender.endRefreshing()
    }
    
    //API 호출
    func getDataFromJson() {
        if let url = URL(string: Science_Video_URL) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(ScienceVideoInput.self, from: data) {
                    //print(json.data)
                    self.scienceVideo = json
                }
                DispatchQueue.main.async {
                    self.scienceCollection.reloadData()
                }
                
            }.resume()
        }
    }
}

extension ScienceVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.scienceVideo?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScienceCVCell", for: indexPath) as! ScienceCVCell
        guard let json = self.scienceVideo else { return cell }
        
        let indexData = json.data[indexPath.row]
        let defaultLink = fileBaseURL
        let url = URL(string: makeStringKoreanEncoded(defaultLink + "/" + indexData.sThumbnail))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.sTitle
        cell.teachersName.text = indexData.sTeacher + " 선생님"
        cell.subjects.text = indexData.sSubject
        cell.subjects.backgroundColor = UIColor(hex: indexData.sSubjectColor)
        cell.starRating.text = indexData.iRating
        
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

extension ScienceVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //나중에 추가
    }
}

extension ScienceVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 225)
    }
}
