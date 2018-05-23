//
//  Sittings+CoreDataProperties.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 23/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//
//

import Foundation
import CoreData


extension Sittings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sittings> {
        return NSFetchRequest<Sittings>(entityName: "Sittings")
    }

    @NSManaged public var color: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var firmness: Int16
    @NSManaged public var id: Int32
    @NSManaged public var time: NSDate?

}
