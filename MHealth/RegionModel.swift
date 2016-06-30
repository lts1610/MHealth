//
//  RegionModel.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import ObjectMapper
import CoreData
import Foundation

@objc(RegionModel)

final class RegionModel: NSManagedObject {
    
    @NSManaged var lattitude: Double
    @NSManaged var longtitude: Double
    @NSManaged var radius: Double
}


extension RegionModel: Mappable {
    
    convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        lattitude <- map["lattitude"]
        longtitude <- map["longitude"]
        radius <- map["radius"]
    }
    
}

class RegionEntity{
    let lattitude: Double
    let longtitude: Double
    let radius: Double
    
    init(object: RegionModel){
        self.lattitude = object.lattitude
        self.longtitude = object.longtitude
        self.radius = object.radius
    }
}