//
//  DoctorModel.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

struct MappingContext: MapContext {
    var ctx : NSManagedObjectContext
    init(context: NSManagedObjectContext){
        self.ctx = context
    }
}

@objc(DoctorModel)
final class DoctorModel: NSManagedObject, Mappable {
    @NSManaged var doctorId: Int
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var available: Bool
    @NSManaged var url: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: NSManagedObjectContext.MR_defaultContext())
    }
    
    required init?(_ map: Map) {
        let ctx = NSManagedObjectContext.MR_defaultContext()
        let entity = NSEntityDescription.entityForName("DoctorModel", inManagedObjectContext: ctx)
        super.init(entity: entity!, insertIntoManagedObjectContext: ctx)
        
        mapping(map)
    }
    func mapping(map: Map) {
        doctorId <- map["doctor_id"]
        name <- map["doctor_name"]
        type <- map["doctor_type"]
        available <- map["doctor_available"]
        url <- map["avatar_url"]
    }
}

extension String {
    
    /// Replace white space character by percent
    var URLEscapedString: String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
    }
    
}
