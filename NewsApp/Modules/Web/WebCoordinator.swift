//
//  WebCoordinator.swift
//  NewsApp
//
//  Created by Egor on 14.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class WebCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    let url: URL
    
    init(navigationController: UINavigationController, url: URL) {
        self.url = url
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WebViewModel(url: url)
        let viewController = WebView(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
        
        return viewModel.didClose
            .take(1)
    }
}
