//
//  Source.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import Foundation

struct Source {
    let id: String
    let name: String
    let description: String
    let url: URL?
    let category: String
    let language: String
    let country: String
    
    init (from object: SourceObject) {
        self.id = object.id
        self.name = object.name
        self.description = object.description
        self.url = URL(string: object.url)
        self.category = object.category
        self.language = object.language
        self.country = object.country
    }
}
