//
//  WebViewModel.swift
//  NewsApp
//
//  Created by Egor on 14.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class WebViewModel {
    let didClose = PublishSubject<Void>()
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}
