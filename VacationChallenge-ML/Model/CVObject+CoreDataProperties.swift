//
//  CVObject+CoreDataProperties.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 19/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//
//

import Foundation
import CoreData


extension CVObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CVObject> {
        return NSFetchRequest<CVObject>(entityName: "CVObject")
    }

    @NSManaged public var difficulty: Int16
    @NSManaged public var objDescription: String?
    @NSManaged public var objName: String?

}
