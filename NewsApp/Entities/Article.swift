//
//  News.swift
//  NewsApp
//
//  Created by Egor on 08.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import Foundation

struct Article {
    let sourceId: String?
    let sourceName: String
    
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date?
    let content: String?
    
    var isFavorite: Bool = false
    
    init(from object: ArticleObject) {
        sourceId = object.source!.id
        sourceName = object.source!.name
        author = object.author
        title = object.title
        description = object.description
        url = object.url
        urlToImage = object.urlToImage
        publishedAt = object.publishedAt.toDate()
        content = object.content
    }
    
    init (from storedArticle: FavoriteArticle) {
        sourceId = storedArticle.sourceId
        sourceName = storedArticle.sourceName
        author = storedArticle.author
        title = storedArticle.title
        description = storedArticle.articleDescription
        url = storedArticle.url
        urlToImage = storedArticle.urlToImage
        publishedAt = storedArticle.publishedAt
        content = storedArticle.content
        isFavorite = storedArticle.isFavorite
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.url == rhs.url
    }
}
