//
//  Result.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import Foundation
import ObjectMapper

class Result<T: Mappable>: Mappable {
    var data: T?
    var message: String?
    var status: Bool = false
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }
}

class ResultArray<T: Mappable> : Mappable {
    var data: [T]?
    var message: String?
    var status: Bool = false
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }

}