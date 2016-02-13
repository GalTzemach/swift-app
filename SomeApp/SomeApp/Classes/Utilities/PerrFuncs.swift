//
//  PerrFuncs.swift
//  SomeApp
//
//  Created by Perry on 2/12/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: - Global Methods

// dispatch block on main queue
public func runOnUiThread(afterDelay seconds: Double = 0.0, block: dispatch_block_t) {
    runBlockAfterDelay(afterDelay: seconds, block: block)
}

// runClosureAfterDelay
public func runBlockAfterDelay(afterDelay seconds: Double = 0.0,
    onQueue: dispatch_queue_t = dispatch_get_main_queue(),
    block: dispatch_block_t) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))) // 2 seconds delay before retry
        dispatch_after(delayTime, dispatch_get_main_queue(), block)
}

public func className(type: AnyClass) -> String {
    return NSStringFromClass(type).componentsSeparatedByString(".").last!
}

// MARK: - "macros"
typealias CompletionClosure = ((AnyObject?) -> Void)?
func WIDTH(frame: CGRect) -> CGFloat {
    return frame.size.width
}

// MARK: - Class

public class PerrFuncs: NSObject {
    static var sharedInstance: PerrFuncs = {
        return PerrFuncs()
    }()

    private override init() {
        super.init()
    }
    
    lazy var imageContainer: UIView = {
        let container = UIView(frame: UIScreen.mainScreen().bounds)
        container.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        // To be a target, it must be an NSObject instance
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnImageContainer:")
        container.addGestureRecognizer(tapGestureRecognizer)
        return container
    }()

    // The UITapGestureRecognizer won't be able to send the selector to the instance if this will be private
    func tappedOnImageContainer(tapGestureRecognizer: UITapGestureRecognizer) {
        self.removeImage()
    }

    func removeImage() {
        imageContainer.animateFade(fadeIn: false) { (doneSuccessfully) in
            self.imageContainer.removeAllSubviews()
            self.imageContainer.removeFromSuperview()
        }
    }

    class func fetchAndPresentImage(imageUrl: String?) {
        guard let imageUrl = imageUrl where imageUrl.characters.count > 0,
            let app = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = app.window
            else { return }
        
        print("fetching \(imageUrl)")

        let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingSpinner.startAnimating()
        sharedInstance.imageContainer.addSubview(loadingSpinner)
        loadingSpinner.pinToSuperViewCenter()

        window.addSubview(sharedInstance.imageContainer)

        let screenWidth = WIDTH(window.frame) //UIScreen.mainScreen().bounds.width
        UIImageView(frame: CGRectMake(0.0, 0.0, screenWidth, screenWidth)).fetchImage(withUrl: imageUrl) { (imageView) in
            if let imageView = imageView as? UIImageView where imageView.image != nil {
                sharedInstance.imageContainer.addSubview(imageView)
                imageView.userInteractionEnabled = false
                imageView.pinToSuperViewCenter()
            } else {
                sharedInstance.removeImage()
            }
        }
    }
}

extension UIImage {
    static func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure) {
        guard let url = NSURL(string: urlString) else { completionClosure?(nil); return }
        
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        // Run on background thread:
        dispatch_async(backgroundQueue) {
            var image: UIImage? = nil
            
            // No matter what, make the callback call on the main thread:
            defer {
                // Run on UI thread:
                dispatch_async(dispatch_get_main_queue()) {
                    completionClosure?(image)
                }
            }

            // The most (and inefficient) simple way to download a photo from the web (no timeout, error handling etc.)
            if let data = NSData(contentsOfURL: url) {
                image = UIImage(data: data)
            }
        }
    }
}

extension UIImageView {
    func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure) {
        guard urlString.characters.count > 0 else { completionClosure?(nil); return }

        UIImage.fetchImage(withUrl: urlString) { (image) in
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    completionClosure?(self)
                }
            }

            guard let image = image as? UIImage else { return }

            self.image = image
            self.contentMode = .ScaleAspectFit
        }
    }
}

//MARK: - Global Extensions

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationBelovedProperty: UInt8 = 0

// Question: What is redundant in this code?

//infix operator 😘 { associativity left precedence 140 }
func 😘(left: NSObject, right: String) throws -> Bool {
    return try left.😘(beloved: right)
}

extension NSObject { // try extending 'AnyObject'...
    //infix operator 😘 { associativity left precedence 140 }
    func 😘(beloved beloved: String) throws -> Bool {
        guard beloved.characters.count > 0 else {
            return false
        }
        
        print("loving \(beloved)")
        
        // "Hard" guard
        //assert(beloved.characters.count > 0, "non-empty strings only")
        
        objc_setAssociatedObject(self, &SompApplicationBelovedProperty, beloved, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }
    
    func 😍() -> String? { // 1
        //print("loving \(right)")
        guard let value = objc_getAssociatedObject(self, &SompApplicationBelovedProperty) as? String else {
            return nil
        }
        
        return value
    }
}

extension UIAlertController {
    
    /**
     A service method that alerts with title and message in the top view controller
     
     - parameter title: The title of the UIAlertView
     - parameter message: The message inside the UIAlertView
     */
    static func alert(title title: String, message: String, dismissButtonTitle:String = "OK", onGone: (() -> Void)? = nil) {
        guard var topController = UIApplication.sharedApplication().keyWindow?.rootViewController else {
            return
        }
        
        // topController should now be the most top view controller
        if let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: dismissButtonTitle, style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            onGone?()
        }))
        
        topController.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    
    class func instantiate(storyboardName storyboardName: String? = nil) -> Self {
        return instantiateFromStoryboardHelper(storyboardName)
    }
    
    private class func instantiateFromStoryboardHelper<T: UIViewController>(storyboardName: String?) -> T {
        let storyboard = storyboardName != nil ? UIStoryboard(name: storyboardName!, bundle: nil) : UIStoryboard(name: "Main", bundle: nil)
        let identifier = NSStringFromClass(T).componentsSeparatedByString(".").last!
        let controller = storyboard.instantiateViewControllerWithIdentifier(identifier) as! T
        return controller
    }
}

extension UIView {
    
    // MARK: - Animations
    public func animateBump(completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut   , animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: completion)
    }
    
    public func animateMoveCenterTo(x x: CGFloat, y: CGFloat, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.center.x = -self.center.x
        self.center.y = -self.center.y
        
        UIView.animateWithDuration(duration, animations: {
            self.center.x = x
            self.center.y = y
            }, completion: completion)
    }
    
    public func animateZoom(zoomIn zoomIn: Bool, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        if zoomIn {
            self.transform = CGAffineTransformMakeScale(0.0, 0.0)
        }
        UIView.animateWithDuration(duration, animations: { () -> Void in
            if zoomIn {
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            } else {
                self.frame.size = CGSizeMake(0.0, 0.0)
            }
            }) { (finished) in
                self.show(show: zoomIn)
                completion?(finished)
        }
    }
    
    public func animateFade(fadeIn fadeIn: Bool, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.alpha = fadeIn ? 0.0 : 1.0
        self.show(show: true)
        UIView.animateWithDuration(duration, animations: {// () -> Void in
            self.alpha = fadeIn ? 1.0 : 0.0
            }) { (finished) in
                self.show(show: fadeIn)
                completion?(finished)
        }
    }
    
    // MARK: - Property setters-like methods

    public func show(show show: Bool, faded: Bool = false) {
        if faded {
            animateFade(fadeIn: show)
        } else {
            self.hidden = !show
        }
    }
    
    // MARK: - Property setters-like methods

    /**
    Recursively remove all receiver’s immediate subviews... and their subviews... and their subviews... and their subviews...
    */
    public func removeAllSubviews() {
        for subView in self.subviews {
            subView.removeAllSubviews()
        }

        print("Removing: \(self), bounds: \(bounds), frame: \(frame):")
        self.removeFromSuperview()
    }
    
    // MARK: - Constraints methods
    
    func stretchToSuperViewEdges(insets: UIEdgeInsets = UIEdgeInsetsZero) {
        // Validate
        guard let superview = superview else { fatalError("superview not set") }
        
        let leftConstraint = constraintWithItem(superview, attribute: .Left, multiplier: 1, constant: insets.left)
        let topConstraint = constraintWithItem(superview, attribute: .Top, multiplier: 1, constant: insets.top)
        let rightConstraint = constraintWithItem(superview, attribute: .Right, multiplier: 1, constant: insets.right)
        let bottomConstraint = constraintWithItem(superview, attribute: .Bottom, multiplier: 1, constant: insets.bottom)
        
        let edgeConstraints = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        
        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraints(edgeConstraints)
    }
    
    func pinToSuperViewCenter(offset: CGPoint = CGPointZero) {
        // Validate
        assert(self.superview != nil, "superview not set")
        let superview = self.superview!
        
        let centerX = constraintWithItem(superview, attribute: .CenterX, multiplier: 1, constant: offset.x)
        let centerY = constraintWithItem(superview, attribute: .CenterY, multiplier: 1, constant: offset.y)
        
        let centerConstraints = [centerX, centerY]
        
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(centerConstraints)
    }
    
    func constraintWithItem(view: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: constant)
    }

}

extension NSURL {
    
    func queryStringComponents() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        // Check for query string
        if let query = self.query {
            // Loop through pairings (separated by &)
            for pair in query.componentsSeparatedByString("&") {
                // Pull key, val from from pair parts (separated by =) and set dict[key] = value
                let components = pair.componentsSeparatedByString("=")
                dict[components[0]] = components[1]
            }
        }
        
        return dict
    }
}