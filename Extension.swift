
import Foundation
import UIKit

extension UIView {
    
    func scale() -> CGFloat {
        return CGFloat(sqrt(Double(transform.a * transform.a + transform.c * transform.c)))
    }
    
    func radian() -> CGFloat {
        return CGFloat(atan2f(Float(transform.b) ,Float(self.transform.a)))
    }
}


extension Bundle {
    
    static func image(name: String) -> UIImage? {
        let bundle = Bundle(for: BundleResource.self)
        return UIImage(named: name , in: bundle, compatibleWith: nil)
    }
}

private class BundleResource{}



