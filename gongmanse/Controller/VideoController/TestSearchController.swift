/***********************************************/
/* TEST용 Controller */
/***********************************************/
import UIKit

/// TEST용 컨트롤러
class TestSearchController: UIViewController {
    
    // MARK: - Property
    
    var clickedText: String?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "키워드를 전달받지 못함"
        label.font = UIFont.appBoldFontWith(size: 20)
        label.textAlignment = .center
        label.textColor = .mainOrange
        label.backgroundColor = .white
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    init(clickedText: String) {
        self.clickedText = clickedText
        label.text = clickedText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        label.clipsToBounds = true
        label.layer.cornerRadius = 50
        label.addShadow()
        view.backgroundColor = .white
        view.addSubview(label)
        label.setDimensions(height: 200, width: 200)
        label.centerX(inView: view)
        label.centerY(inView: view)
    }
    
}
