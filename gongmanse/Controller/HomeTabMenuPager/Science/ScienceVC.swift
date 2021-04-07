import UIKit

class ScienceVC: UIViewController {
    
    var pageIndex: Int!
    
    var scienceVideo: ScienceVideoInput?
    
    let scienceRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var scienceCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scienceCollection.refreshControl = scienceRC
        
        getDataFromJson()
        
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        scienceCollection.reloadData()
        sender.endRefreshing()
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ScienceCRV", for: indexPath) as? ScienceCRV else {
                return UICollectionReusableView()
            }
            return header
        default:
            return UICollectionReusableView()
        }
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
