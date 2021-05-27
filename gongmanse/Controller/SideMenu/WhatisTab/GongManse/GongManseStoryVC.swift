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

        
        manseImage.contentMode = .scaleAspectFit
        manseImage.sizeToFit()
        let image = #imageLiteral(resourceName: "aboutManse") // aboutManse
        
        switch UIScreen.main.scale {
        case 2.0:
            manseImage.image = image.resize(3500)
        case 3.0:
            manseImage.image = image.resize(7000)
        default:
            return 
        }
//        manseImage.image = image.resize(3500)
        print(manseImage.image?.size)
        print(UIScreen.main.scale)
        
        // 0.16615
        // 387.69
        // 2333.33
    }
}
extension UIImage {
    func resize(_ max_size: CGFloat) -> UIImage {
        // adjust for device pixel density
        
        var max_size_pixels: CGFloat = 0.0
        
        max_size_pixels = max_size / UIScreen.main.scale
        
        if UIScreen.main.scale == 2.0 {
            max_size_pixels = max_size / UIScreen.main.scale + 1.0
        }
        
        // work out aspect ratio
        let aspectRatio =  size.width/size.height
        // variables for storing calculated data
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        if aspectRatio > 1 {
            // landscape
            width = max_size_pixels
            height = max_size_pixels / aspectRatio
        } else {
            // portrait
            height = max_size_pixels
            width = max_size_pixels * aspectRatio
        }
        // create an image renderer of the correct size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: UIGraphicsImageRendererFormat.default())
        // render the image
        newImage = renderer.image {
            (context) in
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        // return the image
        return newImage
    }
}

extension UIImage {
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
