//
//  APIType.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import Alamofire

protocol APIType: URLStringConvertible {
    
    ///
    var baseURL: NSURL { get }
    var path: String { get }
    var method: Alamofire.Method { get }
    var parameters: [String: AnyObject]? { get }
    
}

extension APIType {
    
    var baseURL: NSURL {
        return NSURL(string: "https://mhealth-thesulai.c9users.io/")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Alamofire.Method {
        return .POST
    }
    
    var parameters: [String: AnyObject]? {
        return nil
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: path, relativeToURL: baseURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        return request//ParameterEncoding.JSON.encode(request, parameters: parameters).0
    }
    
    var URLString: String {
        return NSURL(string: path, relativeToURL: baseURL)!.absoluteString
    }
}

enum MHealthAPI {
    
    case Location
    case Doctors
    
}


extension MHealthAPI: APIType {
    
    var path: String {
        switch self {
        case .Location: return "location.php"
        case .Doctors: return "doctors.php"
        }
    }
    
}

