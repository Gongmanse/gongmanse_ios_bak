import UIKit

class ExpertConsultationDetailVC: UIViewController {
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var receiveData: ExpertModelData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviAndViewSettings()
        //print(receiveData?.consultation_id)
        
    }
    
    //네비게이션 바와 프로필 뷰 설정
    func naviAndViewSettings () {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
}
