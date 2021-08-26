//
//  Do+CoreDataProperties.swift
//  ToDo
//
//  Created by Vinny Asaro on 1/19/21.
//  Copyright © 2021 Vinny Asaro. All rights reserved.
//
//

import Foundation
import CoreData


extension Do {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Do> {
        return NSFetchRequest<Do>(entityName: "Do")
    }

    @NSManaged public var bio: String?
    @NSManaged public var name: String?
    @NSManaged public var completionStatus: Bool
    @NSManaged public var home: Project?

}
