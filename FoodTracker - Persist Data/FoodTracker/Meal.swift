//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 5/26/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//  See LICENSE.txt for this sample’s licensing information.
//

import UIKit

class Meal: NSObject, NSCoding {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var calories: Int
    var userDescription: String
    var userId: Int
    var id: Int
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let calorieKey = "calories"
        static let userIdKey = "userId"
        static let idKey = "idKey"
        static let descriptionKey = "descriptionKey"
    }

    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, calories: Int, userDescription: String, serverId: Int, userId: Int) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.calories = calories
        self.userDescription = userDescription
        self.id = serverId
        self.userId = userId
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
        aCoder.encodeInteger(calories, forKey: PropertyKey.calorieKey)
        aCoder.encodeObject(userDescription, forKey: PropertyKey.descriptionKey)
        aCoder.encodeInteger(id, forKey: PropertyKey.idKey)
        aCoder.encodeInteger(userId, forKey: PropertyKey.userIdKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        let calories = aDecoder.decodeIntegerForKey(PropertyKey.calorieKey)
        let userDescription = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String
        
        let serverId = aDecoder.decodeIntegerForKey(PropertyKey.idKey)
        let userId = aDecoder.decodeIntegerForKey(PropertyKey.userIdKey)
        
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, calories: calories, userDescription: userDescription, serverId: serverId, userId: userId)
    }

}