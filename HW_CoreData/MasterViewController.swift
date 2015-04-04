//
//  MasterViewController.swift
//  HW_CoreData
//
//  Created by Gena on 31.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, UIAlertViewDelegate {

    var pages: [Page]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        self.navigationItem.rightBarButtonItem = addButton
        
        self.reloadData()
    }
    
    func reloadData() {
        CoreDataManager.instance.getAllPages { (pages) -> () in
            self.pages = pages
            self.tableView.reloadData()
        }
    }

    func addButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Добавить сайт", message: "", preferredStyle: .Alert)
        
        let addAction = UIAlertAction(title: "Добавить", style: .Default) { (_) -> Void in
            let titleTextField = alertController.textFields![0] as UITextField
            let urlTextField = alertController.textFields![1] as UITextField
            self.addPage(titleTextField.text, url: urlTextField.text)
        }
        addAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (_) -> Void in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Название"
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Ссылка"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                addAction.enabled = textField.text != ""
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    func addPage(title: String, url: String) {
        var page = Page()
        page.title = title
        page.stringURL = url
        
        DownloadManager.instance.loadPage(page, success: { (page) -> () in
            self.pages!.append(page)
            CoreDataManager.instance.save()
            self.tableView.reloadData()
        }) { (error) -> () in
            let alertView = UIAlertView(title: "Ошибка", message: error.localizedDescription, delegate: self, cancelButtonTitle: "Отмена")
            alertView.alertViewStyle = .Default
            alertView.show()
        }
        
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pages = self.pages {
            return pages.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as PageCell
        if let page = self.pages?[indexPath.row] {
            cell.title!.text = page.title
            cell.thumbImageView?.image = page.image
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let page = self.pages?[indexPath.row] {
                CoreDataManager.instance.deletePage(page)
                CoreDataManager.instance.save()
                self.pages?.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            if segue.identifier == "showDetail" {
                var detail = segue.destinationViewController as DetailViewController
                if let page = self.pages?[indexPath.row] {
                    detail.data = page.data
                    let stringURL = page.stringURL
                    detail.url = NSURL(string: stringURL)
                }
            }
        }
    }

}

