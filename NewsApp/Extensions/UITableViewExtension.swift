//
//  UITableViewExtension.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit
import RxRealm

extension UITableView {
    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        endUpdates()
    }
}
