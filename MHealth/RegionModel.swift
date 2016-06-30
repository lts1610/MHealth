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

final class RegionModel: NSObject, Mappable {
    
    var lattitude: Double = 0
    var longtitude: Double = 0
    var radius: Double = 0
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        lattitude <- map["lattitude"]
        longtitude <- map["longitude"]
        radius <- map["radius"]
    }
}
