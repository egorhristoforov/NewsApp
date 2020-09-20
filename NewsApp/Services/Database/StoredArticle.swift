//
//  StoredArticle.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RealmSwift

class FavoriteArticle: Object {
    @objc dynamic var sourceId: String? = nil
    @objc dynamic var sourceName: String = ""
    
    @objc dynamic var author: String? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var articleDescription: String? = nil
    @objc dynamic var url: String = ""
    @objc dynamic var urlToImage: String?
    @objc dynamic var publishedAt: Date?
    @objc dynamic var content: String?
    
    @objc dynamic var isFavorite: Bool = false
    
    init (from article: Article) {
        self.sourceId = article.sourceId
        self.sourceName = article.sourceName
        self.author = article.author
        self.title = article.title
        self.articleDescription = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.content = article.content
        self.isFavorite = article.isFavorite
    }
    
    required init() {
        super.init()
    }
}
