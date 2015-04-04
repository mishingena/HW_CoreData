//
//  DetailViewController.swift
//  HW_CoreData
//
//  Created by Gena on 31.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var data: NSData?
    var url: NSURL?
    var allowLoad: Bool = true
    var progressHud: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressHud = MBProgressHUD()
        self.webView.addSubview(self.progressHud!)
        self.progressHud?.show(true)
        self.webView.loadData(self.data, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: self.url)
    }

    
    //MARK: - WebView Delegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return allowLoad
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        allowLoad = false
        self.progressHud?.hide(true)
    }

}

