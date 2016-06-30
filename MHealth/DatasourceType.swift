//
//  DatasourceType.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import Foundation

protocol DatasourceType {
    associatedtype T
    
    var datasource: [T] { get }
    func numberOfSection() -> Int
    func numberOfItemInSection(section: Int) -> Int
    
    subscript(index: NSIndexPath) -> T { get }
}

extension DatasourceType{
    func numberOfSection() -> Int{
        return 1
    }
    func numberOfItemInSection(section: Int) -> Int{
        return datasource.count
    }
    
    subscript(index: NSIndexPath) -> T {
        get{
            return datasource[index.row]
        }
    }

}