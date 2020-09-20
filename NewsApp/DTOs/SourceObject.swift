//
//  SourceObject.swift
//  NewsApp
//
//  Created by Egor on 09.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import ObjectMapper

struct SourceObject: Mappable {
    var id: String!
    var name: String!
    var description: String!
    var url: String!
    var category: String!
    var language: String!
    var country: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        url <- map["url"]
        category <- map["category"]
        language <- map["language"]
        country <- map["country"]
    }
}
