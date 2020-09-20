//
//  SourcesObject.swift
//  NewsApp
//
//  Created by Egor on 09.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import ObjectMapper

struct SourcesObject: Mappable {
    var status: String!
    var sources: [SourceObject] = []
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        sources <- map["sources"]
    }
}
