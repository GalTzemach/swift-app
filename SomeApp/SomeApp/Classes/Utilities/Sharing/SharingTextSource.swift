//
//  SharingTextSource.swift
//  SomeApp
//
//  Created by Perry on 4/14/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

class SharingTextSource: NSObject, UIActivityItemSource {

    // Might change at any version WhatsApp are distributing
    let UIActivityTypeWhatsApp = "net.whatsapp.WhatsApp.ShareExtension"

//    init(image: UIImage) {
//        super.init()
//    }

    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        var shareText = "Yo check this out!"

        switch activityType {
        case UIActivityTypeWhatsApp:
            shareText = "Whazzzzup? 😝" + shareText
        case UIActivityTypeMessage:
            shareText += " (I hope your iMessage is on)"
        case UIActivityTypeMail:
            fallthrough // Consider building an HTML body
        case UIActivityTypePostToFacebook:
            fallthrough // Consider taking a sharing URL in facebook
        default:
            break
        }

        return shareText
    }

    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return "Shared from SomeApp"
    }
}