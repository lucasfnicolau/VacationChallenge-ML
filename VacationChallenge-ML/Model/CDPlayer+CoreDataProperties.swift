//
//  CDPlayer+CoreDataProperties.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 01/08/19.
//  Copyright © 2019 Academy. All rights reserved.
//
//

import Foundation
import CoreData


extension CDPlayer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPlayer> {
        return NSFetchRequest<CDPlayer>(entityName: "CDPlayer")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var victories: Int16

}
