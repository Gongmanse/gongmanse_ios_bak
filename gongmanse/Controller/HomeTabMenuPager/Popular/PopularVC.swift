import UIKit

class PopularVC: UIViewController {
    
    var pageIndex: Int!
    
    var popularVideo = PopularVideoInput(header: PopularVideoHeaderData.init(resultMsg: "", totalRows: "", isMore: ""), body: [PopularVideoData]())
    
    let popularRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var popularCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        popularCollection.refreshControl = popularRC
        
        getDataFromJson()
        
    }
    
    func getDataFromJson() {
        if let url = URL(string: makeStringKoreanEncoded(Popular_Video_URL + "/모든?offset=0&limit=30")) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(PopularVideoInput.self, from: data) {
                    //print(json.body)
                    self.popularVideo.body.append(contentsOf: json.body)
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
        //guard let data = self.popularVideo?.data else { return 0}
        let popularData = self.popularVideo
        return popularData.body.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCVCell", for: indexPath) as! PopularCVCell
        //guard let json = self.popularVideo else { return cell }
        
        let json = self.popularVideo
        let indexData = json.body[indexPath.row]
        let url = URL(string: makeStringKoreanEncoded(indexData.thumbnail))
        
        cell.videoThumbnail.contentMode = .scaleAspectFill
        cell.videoThumbnail.sd_setImage(with: url)
        cell.videoTitle.text = indexData.title
        cell.teachersName.text = indexData.teacherName + " 선생님"
        cell.subjects.text = indexData.subject
        cell.subjects.backgroundColor = UIColor(hex: indexData.subjectColor)
        cell.starRating.text = indexData.rating
        
        if indexData.unit != nil {
            cell.term.isHidden = false
            cell.term.text = indexData.unit
        } else if indexData.unit == "1" {
            cell.term.isHidden = false
            cell.term.text = "i"
        } else if indexData.unit == "2" {
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
