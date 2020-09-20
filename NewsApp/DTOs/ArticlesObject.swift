//
//  NewsObject.swift
//  NewsApp
//
//  Created by Egor on 07.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import ObjectMapper

struct ArticlesObject: Mappable {
    var status: String!
    var totalResults: Int!
    var articles: [ArticleObject] = []
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        totalResults <- map["totalResults"]
        articles <- map["articles"]
    }
}
