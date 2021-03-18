import Foundation
import UIKit

extension UIFont {
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "NanumSquareRoundR", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    class func appBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "NanumSquareRoundB", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    class func applightFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "NanumSquareRoundL", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }    
    class func appEBFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "NanumSquareRoundEB", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }        
}


