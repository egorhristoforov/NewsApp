//
//  ArticleCategory.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit

struct ArticleCategory {
    let name: String
    let image: UIImage?
    
    init(name: String) {
        self.name = name
        image = ArticleCategory.getImage(from: name)
    }
    
    static func getImage(from name: String) -> UIImage? {
        switch name.lowercased() {
        case "general":
            return #imageLiteral(resourceName: "image 2")
        case "technology":
            return #imageLiteral(resourceName: "image 4")
        case "business":
            return #imageLiteral(resourceName: "image 3")
        case "sports":
            return #imageLiteral(resourceName: "image 5")
        case "entertainment":
            return #imageLiteral(resourceName: "image 1")
        case "health":
            return #imageLiteral(resourceName: "image 6")
        case "science":
            return #imageLiteral(resourceName: "image 7")
        default:
            return nil
        }
    }
}
