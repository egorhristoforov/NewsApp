//
//  ArticleObject.swift
//  NewsApp
//
//  Created by Egor on 08.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import ObjectMapper

struct ArticleObject: Mappable {
    var source: ArticleSourceObject!
    var author: String?
    var title: String!
    var description: String?
    var url: String!
    var urlToImage: String?
    var publishedAt: String!
    var content: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        source <- map["source"]
        author <- map["author"]
        title <- map["title"]
        description <- map["description"]
        url <- map["url"]
        urlToImage <- map["urlToImage"]
        publishedAt <- map["publishedAt"]
        content <- map["content"]
    }
}
