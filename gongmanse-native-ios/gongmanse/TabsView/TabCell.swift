import UIKit

class TabCell: UICollectionViewCell {
    private var tabSV: UIStackView!
    
    var tabTitle: UILabel!
    
    var tabIcon: UIImageView!
    
    var indicatorView: UIView!
    
    var indicatorColor: UIColor = .black
    
    override var isSelected: Bool {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.indicatorView.backgroundColor = self.isSelected ? self.indicatorColor : UIColor.clear
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    var tabViewModel: Tab? {
        didSet {
            tabTitle.text = tabViewModel?.title
            tabIcon.image = tabViewModel?.icon
            
            //icon 이 nil이라면 stackView 공간 제거
            (tabViewModel?.icon != nil) ? (tabSV.spacing = 10) : (tabSV.spacing = 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tabSV = UIStackView()
        tabSV.axis = .horizontal
        tabSV.alignment = .center
        tabSV.spacing = 10.0
        addSubview(tabSV)
        
        //탭 아이콘
        tabIcon = UIImageView()
        tabIcon.clipsToBounds = true
        self.tabSV.addArrangedSubview(tabIcon)
        
        //탭 타이틀
        tabTitle = UILabel()
        tabTitle.textAlignment = .center
        self.tabSV.addArrangedSubview(tabTitle)
        
        //탭 아이콘 제약조건
        tabIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tabIcon.heightAnchor.constraint(equalToConstant: 18),
            self.tabIcon.widthAnchor.constraint(lessThanOrEqualToConstant: 18)
        ])
        
        //tabSV 제약조건 추가
        tabSV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabSV.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tabSV.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        setupIndicatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tabTitle.text = ""
        tabIcon.image = nil
    }
    
    func setupIndicatorView() {
        indicatorView = UIView()
        addSubview(indicatorView)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 3),
            indicatorView.widthAnchor.constraint(equalTo: self.widthAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
