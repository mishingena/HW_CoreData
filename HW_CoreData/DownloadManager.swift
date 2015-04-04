//
//  DownloadManager.swift
//  HW_CoreData
//
//  Created by Gena on 02.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
    
    let queue: dispatch_queue_t
    
    class var instance: DownloadManager {
        struct Singleton {
            static let instance = DownloadManager()
        }
        return Singleton.instance
    }
    
    override init() {
        queue = dispatch_queue_create("DownloadManager queue", DISPATCH_QUEUE_CONCURRENT)
    }
    
    func loadPage(page: Page, success: (page: Page) -> (), failture: (error: NSError) -> ()) {
        var error: NSError?
        
        dispatch_async(queue, { () -> Void in
            let group = dispatch_group_create()
            
            dispatch_group_enter(group)
            let pageURL = NSURL(string: page.stringURL)
            
            let downloadPageTask = NSURLSession.sharedSession().dataTaskWithURL(pageURL!, completionHandler: { (data, response, err) -> Void in
                dispatch_group_leave(group)
                if let err = err {
                    error = err
                } else {
                    page.data = data
                }
            })
            downloadPageTask.resume()
            
            dispatch_group_enter(group)
            let stringURL = "http://www.google.com/s2/favicons?domain=" + page.stringURL
            let imageURL = NSURL(string: stringURL)
            
            let downloadImageTask = NSURLSession.sharedSession().dataTaskWithURL(imageURL!, completionHandler: { (data, response, err) -> Void in
                if let err = err {
                    error = err;
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        page.image = UIImage(data: data)!
                    })
                }
                dispatch_group_leave(group)
            })
            downloadImageTask.resume()
           
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let error = error {
                    failture(error: error)
                } else {
                    success(page: page)
                }
            })
            
        })
    }
}
