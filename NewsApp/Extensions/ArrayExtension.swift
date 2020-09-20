//
//  ArrayExtension.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
