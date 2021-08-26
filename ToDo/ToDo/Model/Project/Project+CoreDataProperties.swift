//
//  Project+CoreDataProperties.swift
//  ToDo
//
//  Created by Vinny Asaro on 1/19/21.
//  Copyright © 2021 Vinny Asaro. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var bio: String?
    @NSManaged public var name: String?
    @NSManaged public var completionStatus: Bool
    @NSManaged public var dos: NSSet?

}

// MARK: Generated accessors for dos
extension Project {

    @objc(addDosObject:)
    @NSManaged public func addToDos(_ value: Do)

    @objc(removeDosObject:)
    @NSManaged public func removeFromDos(_ value: Do)

    @objc(addDos:)
    @NSManaged public func addToDos(_ values: NSSet)

    @objc(removeDos:)
    @NSManaged public func removeFromDos(_ values: NSSet)

}
