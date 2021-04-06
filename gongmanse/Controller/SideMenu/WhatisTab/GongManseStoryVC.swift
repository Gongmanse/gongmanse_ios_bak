//
//  GongManseStoryVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit

class GongManseStoryVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var manseImage: UIImageView!
    
    
    var pageIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        manseImage.sizeToFit()
        
    }

}
