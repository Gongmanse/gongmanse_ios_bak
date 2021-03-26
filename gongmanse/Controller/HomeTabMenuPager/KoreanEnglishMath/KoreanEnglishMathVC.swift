import UIKit

class KoreanEnglishMathVC: UIViewController {
    
    var pageIndex: Int!
    
    let koreanEnglishMathRC: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var koreanEnglishMathCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        koreanEnglishMathCollection.refreshControl = koreanEnglishMathRC
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        koreanEnglishMathCollection.reloadData()
        sender.endRefreshing()
    }
}

extension KoreanEnglishMathVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanEnglishMathCVCell", for: indexPath) as? KoreanEnglishMathCVCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "KoreanEnglishMathTitleCVCell", for: indexPath) as? KoreanEnglishMathTitleCVCell else {
                return UICollectionReusableView()
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //나중에 추가
    }
}

extension KoreanEnglishMathVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 225)
    }
}
