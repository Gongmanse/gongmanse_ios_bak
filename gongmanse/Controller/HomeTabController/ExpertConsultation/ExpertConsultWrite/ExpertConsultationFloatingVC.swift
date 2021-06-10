import UIKit
import Photos
import Alamofire

protocol ExpertConsultationFloatingVCDelegate: AnyObject {
    func sendButtonSelected()
}

class ExpertConsultationFloatingVC: UIViewController, UITextViewDelegate {
    
    //ExpertConsultView전체 변수들
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var uploadImageCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //alertView 변수들
    @IBOutlet weak var alertViewBackground: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitleView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var selectVideo: UIButton!
    
    let imagePicker = UIImagePickerController()
    var images = [UIImage]()
    
    var isEmptyImage: Bool = false
    var floatingDelegate: ExpertConsultationFloatingVCDelegate?
    
    //var allPhotos: PHFetchResult<PHAsset>!
    //let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSettings()
        answerTextViewSettings()
        writeBtnSettings()
        alertViewSettings()
        placeholderSetting()
        
        //pageView.numberOfPages = images.count
        pageView.currentPage = 0
        pageView.isEnabled = false
        pageView.isHidden = true
        
        writeBtn.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        writeBtn.isEnabled = false
        
        alertViewBackground.isHidden = true
        
        uploadImageCollectionView.register(UINib(nibName: "ConsultUploadImageDefaultCell", bundle: nil), forCellWithReuseIdentifier: "ConsultUploadImageDefaultCell")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func placeholderSetting() {
        answerTextView.delegate = self
        answerTextView.text = "질문을 입력해 주세요"
        answerTextView.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            writeBtn.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
            writeBtn.isEnabled = false
        } else {
            writeBtn.backgroundColor = .mainOrange
            writeBtn.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "질문을 입력해 주세요"
            textView.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        }
    }
    
    func alertViewSettings() {
        self.alertTitleView.layer.addBorder([.bottom], color: .mainOrange, width: 3.0)
        self.alertView.layer.cornerRadius = 13
        self.alertTitleView.layer.cornerRadius = 13
    }
    
    func navigationBarSettings() {
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "전문가 상담"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func answerTextViewSettings() {
        //답변 텍스트 뷰 라운딩 처리 및 Border 추가
        answerTextView.layer.cornerRadius = 13
        answerTextView.layer.borderWidth = 2.0
        answerTextView.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        answerTextView.backgroundColor = .clear
    }
    
    func writeBtnSettings() {
        //작성하기 버튼 라운딩 처리
        writeBtn.layer.cornerRadius = 8
        writeBtn.layer.shadowColor = UIColor.gray.cgColor
        writeBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        writeBtn.layer.shadowRadius = 5
        writeBtn.layer.shadowOpacity = 0.3
    }
    
    @IBAction func writeBtnAction(_ sender: Any) {
        
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(self.answerTextView.text!)".data(using: .utf8)!, withName: "question")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")

        }, to: "https://api.gongmanse.com/v1/my/expert/consultations_urgent").response { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
                self.didSuccessPostAPI()
                print(response)
            case.failure:
                print("error")
            }
        }
        
//        let url = "https://api.gongmanse.com/v1/my/expert/consultations_urgent"
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 10
//
//        //POST 로 보낼 정보
//        let params = ["question": answerTextView.text!, "token": Constant.token] as Dictionary
//
//        //httpBody 에 Parameters 추가
//        do {
//            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
//        } catch {
//            print("http Body Error")
//        }
//
//        AF.request(request).responseString { (response) in
//            switch response.result {
//            case .success:
//                print("POST 성공")
//            case .failure:
//                print("POST 실패")
//            }
//        }
        floatingDelegate?.sendButtonSelected()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSuccessPostAPI() {
        self.view.layoutIfNeeded()
    }
    
    @IBAction func addImageAndVideo(_ sender: Any) {
        if images.count == 3 {
            let alertController = UIAlertController(title: "알림", message: "사진 및 영상은 최대 3개까지 등록할 수 있습니다.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else {
            alertViewBackground.isHidden = false
        }
        
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        alertViewBackground.isHidden = true
    }
    
    //사진 불러오기
    @IBAction func selectPhotoAction(_ sender: Any) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            //허용된 상태
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else if status == .denied {
            //허용 안한 상태
            setAuthAlertAction()
        } else if status == .restricted {
            //제한됨
        } else if status == .notDetermined {
            //결정 안됨 (아래와 같이 시스템 팝업 띄움)
            PHPhotoLibrary.requestAuthorization({ (result: PHAuthorizationStatus) in
                switch result {
                case .authorized:
                    break
                case .denied:
                    break
                default:
                    break
                }
            })
        }
    }
    
    func setAuthAlertAction() {
        let authAlert = UIAlertController(title: "사진첩 권한 요청", message: "사진첩 권한을 허용해야만 앨범을 사용하실 수 있습니다.", preferredStyle: .alert)
        let cancelAlertAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        let allowAlertAction = UIAlertAction(title: "확인", style: .default, handler: { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        authAlert.addAction(cancelAlertAction)
        authAlert.addAction(allowAlertAction)
        self.present(authAlert, animated: true, completion: nil)
    }
    
    @IBAction func selectVideoAction(_ sender: Any) {
    }
}

extension ExpertConsultationFloatingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConsultUploadImageCVCell", for: indexPath) as! ConsultUploadImageCVCell
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
            print(images[indexPath.item])
        }
        
        if images.count == 0 {
            pageView.isHidden = true
        } else if images.count == 1 {
            pageView.isHidden = false
            pageView.numberOfPages = 1
        } else if images.count == 2 {
            pageView.numberOfPages = 2
        } else if images.count == 3 {
            pageView.numberOfPages = 3
        }
        
        cell.index = indexPath
        cell.delegate = self
        
        return cell
        
        
        //            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConsultUploadImageDefaultCell", for: indexPath) as? ConsultUploadImageDefaultCell else { return UICollectionViewCell() }
        //
        //            cell.defaultImage.image = UIImage(named: "photoDefault")
        //
        //            return cell
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl(scrollView: scrollView)
    }
    
    func updatePageControl(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.bounds.size.width)
        let count = 3
        let currentPageNumber = Int(pageNumber) % count
        pageView.currentPage = currentPageNumber
    }
}

extension ExpertConsultationFloatingVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = uploadImageCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension ExpertConsultationFloatingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true, completion: nil)
        alertViewBackground.isHidden = true
        
        images.insert(image, at: 0)
        uploadImageCollectionView.reloadData()
    }
}

extension ExpertConsultationFloatingVC: ImageDeleteProtocol {
    func deleteImage(index: Int) {
        images.remove(at: index)
        uploadImageCollectionView.reloadData()
    }
}
