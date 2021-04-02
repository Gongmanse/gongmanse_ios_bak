import UIKit

class RecommendVC: UIViewController {
    
    var pageIndex: Int!
    
    var recommendVideo: RecommendVideoInput?
    
    let recommendRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var recommendCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendCollection.refreshControl = recommendRC
        
        if let url = URL(string: Recommend_Video_URL) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(RecommendVideoInput.self, from: data) {
                    print(json.data)
                    self.recommendVideo = json
                }
                DispatchQueue.main.async {
                    self.recommendCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        recommendCollection.reloadData()
        sender.endRefreshing()
    }
}

extension RecommendVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.recommendVideo?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCVCell", for: indexPath) as! RecommendCVCell
        guard let json = self.recommendVideo else { return cell}
        
        let indexData = json.data[indexPath.row]
        let defaultLink = fileBaseURL
        let completeLink = defaultLink + "/" + indexData.sThumbnail
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.downloadedFrom(link: completeLink)
        cell.videoTitle.text = indexData.sTitle
        cell.teachersName.text = indexData.sTeacher
        cell.subjects.text = indexData.sSubject
        cell.starRating.text = indexData.iRating
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RecommendCRV", for: indexPath) as? RecommendCRV else {
                return UICollectionReusableView()
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

extension RecommendVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //나중에 추가
    }
}

extension RecommendVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 225)
    }
}

//다시 코드 작성해야할듯 안먹힘 ㅡㅡ;;
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
