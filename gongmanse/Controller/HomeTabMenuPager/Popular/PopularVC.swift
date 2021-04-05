import UIKit

class PopularVC: UIViewController {
    
    var pageIndex: Int!
    
    var popularVideo: PopularVideoInput?
    
    let popularRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var popularCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        popularCollection.refreshControl = popularRC
        
        if let url = URL(string: Popular_Video_URL) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(PopularVideoInput.self, from: data) {
                    print(json.data)
                    self.popularVideo = json
                }
                DispatchQueue.main.async {
                    self.popularCollection.reloadData()
                }
                
            }.resume()
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        popularCollection.reloadData()
        sender.endRefreshing()
    }
}

extension PopularVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.popularVideo?.data else { return 0}
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCVCell", for: indexPath) as! PopularCVCell
        guard let json = self.popularVideo else { return cell }
        
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
}

extension PopularVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TestVC") as! TestVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PopularVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 225)
    }
}
