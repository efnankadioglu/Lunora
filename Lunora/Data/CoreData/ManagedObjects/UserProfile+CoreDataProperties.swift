//
//  UserProfile+CoreDataProperties.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 10.11.2025.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    @NSManaged public var uid: String?    
    @NSManaged public var avatarImageData: Data?
    @NSManaged public var motivation: String?
    @NSManaged public var name: String?
    @NSManaged public var username: String?

}

extension UserProfile : Identifiable {

}
