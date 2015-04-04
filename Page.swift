//
//  Page.swift
//  HW_CoreData
//
//  Created by Gena on 02.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(Page)
class Page: NSManagedObject {

    @NSManaged var image: UIImage
    @NSManaged var stringURL: String
    @NSManaged var title: String
    @NSManaged var data: NSData
    
    class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("Page", inManagedObjectContext: CoreDataManager.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Page.entity, insertIntoManagedObjectContext: CoreDataManager.instance.context)
    }

}
