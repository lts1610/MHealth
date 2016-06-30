//
//  APIProvider.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import RxAlamofire
import Alamofire

struct APIProvider {
    
    static let shareProvider: Manager = {
        
        let configuration: NSURLSessionConfiguration = {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.URLCache = nil
            config.timeoutIntervalForRequest = 60
            config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
            
            return config
        }()
        
        return Manager(configuration: configuration)
    }()
}