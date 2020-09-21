//
//  StringExtensions.swift
//  NewsApp
//
//  Created by Egor on 08.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = formatter.date(from: self)
        
        return date
    }
}
