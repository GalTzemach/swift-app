//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import Alamofire

class MainViewController: UIViewController, LeftMenuViewControllerDelegate, UITextViewDelegate {
    static let projectLocationInsideGitHub = "https://github.com/PerrchicK/swift-app"
    var reachabilityManager: NetworkReachabilityManager?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reachabilityManager = NetworkReachabilityManager()
        reachabilityManager?.listener = { [weak self] (status: NetworkReachabilityManager.NetworkReachabilityStatus) -> () in
            📘("Network reachability status changed: \(status)")
            switch status {
            case .NotReachable:
                self?.navigationController?.navigationBar.barTintColor = UIColor.redColor()
            case .Reachable(NetworkReachabilityManager.ConnectionType.EthernetOrWiFi): fallthrough
            case .Reachable(NetworkReachabilityManager.ConnectionType.WWAN):
                self?.navigationController?.navigationBar.barTintColor = nil
            default:
                break
            }
        }
        reachabilityManager?.startListening()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let lastCrashCallStack = NSUserDefaults.load(key: "last crash") as? [String] {
            UIAlertController.makeAlert(title: "last crash", message: "\(lastCrashCallStack)")
                .withAction(UIAlertAction(title: "fine", style: .Cancel, handler: nil))
                .withAction(UIAlertAction(title: "delete", style: .Default, handler: { (alertAction) in
                    NSUserDefaults.remove(key: "last crash").synchronize()
                }))
                .show()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName(InAppNotifications.CloseDrawer, object: nil)
    }

    // MARK: - LeftMenuViewControllerDelegate
    func leftMenuViewController(leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        switch selectedOption {
        case LeftMenuOptions.SwiftStuff.OperatorsOverloading:
            navigationController?.pushViewController(OperatorsViewController.instantiate(), animated: true)
        case LeftMenuOptions.Concurrency.GCD:
            navigationController?.pushViewController(ConcurrencyViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.Views_Animations:
            navigationController?.pushViewController(AnimationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.CollectionView:
            navigationController?.pushViewController(CollectionContainerViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.Data:
            navigationController?.pushViewController(DataViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.CommunicationLocation:
            navigationController?.pushViewController(CommunicationViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.Notifications:
            navigationController?.pushViewController(NotificationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.ImagesCoreMotion:
            navigationController?.presentViewController(ImagesAndMotionViewController.instantiate(), animated: true, completion: nil)
        default:
            UIAlertController.alert(title: "Under contruction 🔨", message: "to be continued... 😉")
            📘("to be continued...")
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        📘("interacting with URL: \(URL)")
        return URL.absoluteString == MainViewController.projectLocationInsideGitHub
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return false
    }
}