//
//  ShareDialog.swift
//  gongmanse
//
//  Created by H on 2021/08/02.
//

import UIKit

class ShareDialog: UIViewController {

    public typealias Callback = (_ type: Int) -> Void
    private var action: Callback?
    
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnKakao: UIButton!
    
    static func show(_ vc: UIViewController,
                     action: Callback? = nil) {
        let popup = ShareDialog("ShareDialog", action: action)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        vc.present(popup, animated: true, completion: nil)
    }
    
    convenience init(_ nibName: String?, action: Callback?) {
        self.init(nibName: nibName, bundle: nil)
        
        self.action = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnFacebook.alignImageAndTitleVertically()
        btnKakao.alignImageAndTitleVertically()
    }
    
    @IBAction func onBackground(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFacebook(_ sender: Any) {
        self.dismiss(animated: true) {
            self.action?(1)
        }
    }
    
    @IBAction func onKakaoTalk(_ sender: Any) {
        self.dismiss(animated: true) {
            self.action?(2)
        }
    }

}

extension UIButton {
  func alignImageAndTitleVertically(padding: CGFloat = 9.0) {
        let imageSize = imageView!.frame.size
        let titleSize = titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding

        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}
