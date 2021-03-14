

import Foundation
import UIKit

open class EditableView : UIImageView, UIGestureRecognizerDelegate {
    
    open var guidelineColor : UIColor = .gray
    
    open var isDisabled : Bool = false
    
    open var imageTintColor : UIColor?  {
        didSet {
            if imageTintColor == nil {
                return
            }
            
            if let image = self.image {
                self.image = image.withTintColor(imageTintColor ?? UIColor.black)
            }
        }
    }
    
    open var isGuidelineEnabled : Bool = true

    
    open override var bounds: CGRect {
        didSet {
            drawFrameView()
        }
    }
    

    open override var image: UIImage? {

        didSet {
            frameView.removeFromSuperview()
            guard let image = image else { return }
            let oldCenter = self.center
            let ratio = self.scale()
            
            
            transform = self.transform.scaledBy(x: 1/ratio, y: 1/ratio)
            bounds.size = CGSize(width: self.bounds.width * ratio, height: self.bounds.height * ratio)
            
            setNeedsDisplay()
            center = oldCenter
            
            drawFrameView()
        }
    }

    private var imageName : String = ""
    private var deleteIconView : DeleteIconView?
    
    private var deleteIcon: UIImage = Bundle.image(name : "btDelete")!
    
    private var verticalLine: UIView = UIView(frame: .zero)
    private var horizontalLine: UIView = UIView(frame: .zero)
    
    var frameView : EditableFrameView = EditableFrameView(frame: .zero)
    
    private var isDoubleFingering = false
    private var isPreviousVerticalGenerated = false
    private var isPreviousHorizantalGenerated = false
    
    private var isPreviousDiagonalGenerated = false
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        //NotificationManager.shared.notifyFocusDisable(exclusion : self.hashValue)
    }
    
    override public init(image: UIImage?) {
        super.init(image: image)
        initialize()
        //NotificationManager.shared.notifyFocusDisable(exclusion : self.hashValue)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
        self.center = coder.decodeCGPoint(forKey: "center") as CGPoint
        contentMode = .scaleAspectFit
        focus(enable : false)
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(self.center, forKey: "center")
    }
    
    deinit {

        NotificationCenter.default.removeObserver(self)
    }
    
    func initialize() {
        prepareGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(notifyFocus(_:)), name: Notification.Name("focus"), object: nil)
        self.isUserInteractionEnabled = true
    
        contentMode = .scaleAspectFit
    }
    
    open override func didMoveToSuperview() {
        guard let superview = superview else {
            deleteIconView?.removeFromSuperview()
            frameView.removeFromSuperview()
            return
        }
        
        contentMode = .scaleAspectFit
        prepareGuideline()
        self.center = CGPoint(x: superview.frame.width/2.0, y: superview.frame.height/2.0)
    }
    
    public func focus(enable : Bool) {
        if isDisabled { return }
        
        if enable  {
           // NotificationManager.shared.notifyFocusDisable(exclusion : self.hashValue, type: self.accessibilityLabel!)
            isDoubleFingering = false
            drawFrameView()
        }
        else {
            frameView.removeFromSuperview()
            deleteIconView?.removeFromSuperview()
        }
        
    }

    public func destroy() {
        self.removeFromSuperview()
        frameView.removeFromSuperview()
        deleteIconView?.removeFromSuperview()
    }
    
    func drawFrameView() {
        guard let superview = superview else {return}
        
        frameView.removeFromSuperview()
        deleteIconView?.removeFromSuperview()
        
        let ratio = self.scale()
        
        frameView = EditableFrameView(frame: CGRect(x: superview.frame.origin.x + self.frame.origin.x - 5, y: superview.frame.origin.y + self.frame.origin.y - 5, width: self.bounds.width * ratio + 10, height: self.bounds.height * ratio + 10) )
        superview.insertSubview(frameView, belowSubview: self)
        frameView.transform = frameView.transform.rotated(by: self.radian())
        frameView.center = CGPoint(x: superview.frame.origin.x + self.frame.midX, y: superview.frame.origin.y + self.frame.midY)
        
        deleteIconView = DeleteIconView(image : deleteIcon, targetView: self)
        moveIcon(origin : self.frame.origin)
        superview.insertSubview(deleteIconView!, belowSubview: self)

        applyDeleteButton()
    }
    
    @objc func notifyFocus(_ notification: Notification) {
        let viewId = notification.userInfo?["id"] as! Int
        
        if viewId == 0 {
           // focus(enable : false)

        } else {
            if viewId != self.hashValue {
                focus(enable : false)
            }
        }
    }
    
    
    func prepareGuideline() {
        if isGuidelineEnabled == false { return }
        
        guard let superview = superview else {return}
    
        verticalLine = UIView(frame: CGRect(x: 0, y: 0,width: 1, height: superview.frame.height))
        verticalLine.center = CGPoint(x: superview.frame.width/2, y: superview.frame.height/2)
        verticalLine.backgroundColor = guidelineColor
        verticalLine.isHidden = true
        
        horizontalLine = UIView(frame: CGRect(x: 0, y: 0,width: superview.frame.width, height: 1))
        horizontalLine.center = CGPoint(x: superview.frame.width/2, y: superview.frame.height/2)
        horizontalLine.backgroundColor = guidelineColor
        horizontalLine.isHidden = true
        
        superview.addSubview(verticalLine)
        superview.addSubview(horizontalLine)
    }
    
    func prepareGestureRecognizer() {
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotationRecognizer.delegate = self
        addGestureRecognizer(rotationRecognizer)

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchRecognizer.delegate = self
        addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if isDisabled { return }
        
        isDoubleFingering = true
        gesture.view?.transform = (gesture.view?.transform.rotated(by: gesture.rotation))!
    
        applyRotation(gesture)
        checkDiagnonalGuideline()
        frameView.removeFromSuperview()
        deleteIconView?.removeFromSuperview()
        if gesture.state == .ended {
            initGuidelineFlag()
            drawFrameView()
        }
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if isDisabled { return }
        
        isDoubleFingering = true
        applyPinch(gesture)
 
        gesture.scale = 1
        frameView.removeFromSuperview()
        deleteIconView?.removeFromSuperview()

        if gesture.state == .ended {
            
            initGuidelineFlag()
            drawFrameView()
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isDisabled { return }
        
        if isDoubleFingering == true && gesture.numberOfTouches <= 1 {
            isDoubleFingering = false
            return
        }
        
        applyPan(gesture)

        checkVerticalHorizantalGuideline()
        frameView.removeFromSuperview()
        deleteIconView?.removeFromSuperview()
        if gesture.state == .ended {
            initGuidelineFlag()
            drawFrameView()
        }
    }
    
    func initGuidelineFlag() {
        verticalLine.isHidden = true
        horizontalLine.isHidden = true
        
        isPreviousVerticalGenerated = false
        isPreviousHorizantalGenerated = false
    
        isPreviousDiagonalGenerated = false
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        focus(enable : true)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDoubleFingering = false
        initGuidelineFlag()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDoubleFingering = false
        initGuidelineFlag()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        if self == view && isDisabled == true{
            return nil
        }
        
        return view
    }
    
    private func applyRotation( _ gesture: UIRotationGestureRecognizer) {
        gesture.rotation = 0
    }
    
    private func applyPan(_ gesture: UIPanGestureRecognizer) {
        if gesture.numberOfTouches >= 2 { return }
        
        let translation  = gesture.translation(in: superview!)
        gesture.setTranslation(CGPoint.zero, in: superview!)
        let newPosition = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        
        center = newPosition
    }
    
    private func applyPinch(_ gesture: UIPinchGestureRecognizer) {
        gesture.view!.transform = gesture.view!.transform.scaledBy(x: gesture.scale, y: gesture.scale)

        let ratio = self.scale()
        
        transform = self.transform.scaledBy(x: 1/ratio, y: 1/ratio)
        bounds.size = CGSize(width: self.bounds.width * ratio, height: self.bounds.height * ratio)
    }
    
    private func checkDiagnonalGuideline() {
        if isGuidelineEnabled == false { return }
        
        let radians : Double = Double(atan2f(Float(self.transform.b), Float(self.transform.a)));
        let degrees = radians * (180 / .pi);

        var isNeedGenerated = false

        let generator = UIImpactFeedbackGenerator(style: .light)
        if -2 <= degrees && degrees <= 2 {

            let diff = 0.0 - radians
            transform = transform.rotated(by: CGFloat(diff))
            isNeedGenerated = true
        }
        else if -92 <= degrees && degrees <= -88 {
            let diff =  deg2rad(-90) - radians
            transform = transform.rotated(by: CGFloat(diff))
            isNeedGenerated = true
        }
        else if 88 <= degrees && degrees <= 92 {
            let diff =  deg2rad(90) - radians
            transform = transform.rotated(by: CGFloat(diff))
            isNeedGenerated = true
        }
        else if 178 <= degrees || degrees <= -178 {
            let diff =  deg2rad(180) - radians
            transform = transform.rotated(by: CGFloat(diff))
            isNeedGenerated = true
        }
        else {
            isPreviousDiagonalGenerated = false
        }
        
        if (isNeedGenerated ) && !isPreviousDiagonalGenerated {
            generator.impactOccurred()
            isPreviousDiagonalGenerated = true
        }

        else if (!isNeedGenerated){
            isPreviousDiagonalGenerated = false
        }
    }

    
    private func checkVerticalHorizantalGuideline() {
        if isGuidelineEnabled == false { return }
        
        let point = self.center
            
        var isNeedVerticalGenerated = false
        var isNeedHorizontalGenerated = false
            
        let centerX = (superview?.frame.width)! / 2.0
        let centerY = (superview?.frame.height)! / 2.0
        let generator = UIImpactFeedbackGenerator(style: .light)
            
        if centerX - 3.0 < point.x &&  point.x < centerX  + 3.0 {
            center.x = centerX
            verticalLine.isHidden = false
            isNeedVerticalGenerated = true
        } else {
            verticalLine.isHidden = true
            isPreviousVerticalGenerated = false
        }
            
        if centerY - 3.0 < point.y &&  point.y < centerY  + 3.0 {
            center.y = centerY
            horizontalLine.isHidden = false
            isNeedHorizontalGenerated = true
        }else {
            horizontalLine.isHidden = true
            isPreviousHorizantalGenerated = false
        }
            
        if (isNeedVerticalGenerated ) && !isPreviousVerticalGenerated {
            generator.impactOccurred()
            isPreviousVerticalGenerated = true
        }
        else if (isNeedHorizontalGenerated) && !isPreviousHorizantalGenerated {
            generator.impactOccurred()
            isPreviousHorizantalGenerated = true
            
        }
        else if (!isNeedVerticalGenerated) {
            isPreviousVerticalGenerated = false
            
        }
        else if (!isNeedHorizontalGenerated){
            isPreviousHorizantalGenerated = false
        }
    }

    private func applyDeleteButton() {
        let originalCenter: CGPoint = center.applying(transform.inverted())
        let topleft = pointWith(originalCenter: originalCenter, multipliedWidth: -1 , multipliedHeight: -1);
        moveIcon(origin : topleft)
    }
    
    private func drawDeleteIcon() {
        if deleteIconView == nil {
            deleteIconView = DeleteIconView(image : deleteIcon, targetView: self)
        }
        moveIcon(origin : self.frame.origin)
        superview?.addSubview(deleteIconView!)
    }
    
    private func moveIcon(origin : CGPoint) {
        guard let superview = superview else {
            return
        }
        deleteIconView?.center = CGPoint(x : origin.x - 5 + superview.frame.origin.x, y : origin.y - 5 +  superview.frame.origin.y)
    }
    
    private func pointWith(originalCenter: CGPoint, multipliedWidth: CGFloat, multipliedHeight: CGFloat) -> CGPoint {
        var x = originalCenter.x
        x += bounds.width  / 2 * multipliedWidth

        var y = originalCenter.y
        y += bounds.height / 2 * multipliedHeight

        var result = CGPoint(x: x, y: y).applying(transform)
        result.x += transform.tx
        result.y += transform.ty

        return result
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         return true
    }


    private func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}

class EditableFrameView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.lineDashPattern = [3, 3]
        layer.frame = self.bounds
        layer.fillColor = nil
        layer.path = UIBezierPath(rect: self.bounds).cgPath
        self.layer.addSublayer(layer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if self == view {
            return nil
        }
        
        return view
    }
}


class DeleteIconView : UIImageView {

    private weak var targetView : UIView?

    init(image: UIImage?, targetView : UIView) {
        super.init(image: image)
        self.targetView = targetView
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.targetView = coder.decodeObject(forKey: "targetView") as? UIView
        self.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.removeFromSuperview()
        targetView?.removeFromSuperview()
        if let frameView = (targetView as? EditableView)?.frameView {
            frameView.removeFromSuperview()
        }
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.targetView, forKey: "targetView")
    }
}
