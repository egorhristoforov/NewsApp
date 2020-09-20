//
//  ArticleSourceObject.swift
//  NewsApp
//
//  Created by Egor on 08.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import ObjectMapper

struct ArticleSourceObject: Mappable {
    var id: String?
    var name: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
