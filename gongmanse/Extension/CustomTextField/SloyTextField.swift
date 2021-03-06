/*
 * 작성자 : 김우성
 * 사용 시, UITextField 객체 생성 후 class를 SloyTextField로 작성하면 됩니다. FloatingTextField를 희망하면, FloatingTextField를 class로 선택하면 됩니다.
 * Placeholder가 위로 이동할 때, 색상을 변경하고 싶다면, MARK: Color Chagne 부분을 변경하시면 됩니다.
 * 03.19(금) 기준 SloyTextField 만 사용하고 있음.
 */



import UIKit

private extension TimeInterval {
    static let animation250ms: TimeInterval = 0.25
}

private extension UIColor {
    static let inactive: UIColor = .progressBackgroundColor
}

private enum Constants {
    static let offset: CGFloat = 8
    static let placeholderSize: CGFloat = 10
}

final class SloyTextField: UITextField {
    
    // 유효성검사 통과 여부를 확인하기 위한 프로퍼티
    var isVailedIndex: Bool = true
    
    // MARK: - Subviews

    let border = UIView()
    private let label = UILabel()

    // MARK: - Private Properties
    
    // MARK: startingPoint 값 만큼 우측으로 Placehoder와 상단으로 animation되는 Label 위치 이동.
    private let startingPoint: CGFloat = 25
    
    private var labelHeight: CGFloat {
        ceil(font?.withSize(Constants.placeholderSize).lineHeight ?? 0)
    }

    private var textHeight: CGFloat {
        ceil(font?.lineHeight ?? 0)
    }

    private var isEmpty: Bool {
        text?.isEmpty ?? true
    }

    private var textInsets: UIEdgeInsets {
        // MARK: UITextField 시작 위치 선정, left Parameter에 값 기입할 것.
        UIEdgeInsets(top: Constants.offset + labelHeight, left: startingPoint, bottom: Constants.offset, right: 0)
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UITextField

    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 2)
        updateLabel(animated: false)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: textInsets.top + textHeight + textInsets.bottom)
    }

    override var placeholder: String? {
        didSet {
            label.text = placeholder
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.inactive
            ])
        }
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    // MARK: - Private Methods

    private func setupUI() {
        borderStyle = .none

        border.backgroundColor = .inactive
        border.isUserInteractionEnabled = false
        addSubview(border)

        label.textColor = .inactive
        label.font = font?.withSize(Constants.placeholderSize)
        label.text = placeholder
        label.isUserInteractionEnabled = false
        addSubview(label)
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.inactive
        ])

        addTarget(self, action: #selector(handleEditing), for: .allEditingEvents)
    }

    @objc
    private func handleEditing() {
        updateLabel()
        updateBorder()
    }

    private func updateBorder() {
        // MARK: UITextField 클릭 시, 하단 Border(구분선) 색상 설정
        
        // 유효성조건 만족에 따른 하단 보더 색상 변경
        let borderColor = isFirstResponder ? UIColor.mainOrange : (isVailedIndex ? .inactive : .red)
        
        UIView.animate(withDuration: .animation250ms) {
            self.border.backgroundColor = borderColor
            self.leftView?.tintColor = self.isFirstResponder ? .mainOrange : .progressBackgroundColor
        }
    }

    private func updateLabel(animated: Bool = true) {
        let alpha: CGFloat = isEmpty ? 0 : 1
        let y = isEmpty ? labelHeight * 0.5 : 4
        // MARK: 위로 올라가는 Label의 시작위치 조정, x parameter에 값을 조정할 것.
        let labelFrame = CGRect(x: startingPoint, y: y, width: bounds.width, height: labelHeight)

        guard animated else {
            label.frame = labelFrame
            label.alpha = alpha
            return
        }

        UIView.animate(withDuration: .animation250ms) {
            self.label.frame = labelFrame
            self.label.alpha = alpha
            // MARK: Color Change
            self.label.textColor = .mainOrange
            
        }
    }
}
