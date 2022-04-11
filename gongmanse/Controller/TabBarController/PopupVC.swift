//
//  PopupVC.swift
//  gongmanse
//
//  Created by 조철희 on 2022/04/11.
//
import UIKit

class PopupVC : UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_1day_close: UIButton!
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btn_1day_close {
            // set 1day visibility
            let dateformatter: DateFormatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateformatter.string(from: Date())
            
            UserDefaults.standard.setValue(dateString, forKey: "popup")
        }
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        print("PopupVC viewDidLoad")
    }
    
    override func viewDidLayoutSubviews() {
        backgroundView.layer.cornerRadius = 10
    }
}
