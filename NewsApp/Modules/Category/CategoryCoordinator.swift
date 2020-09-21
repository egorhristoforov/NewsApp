//
//  CategoryCoordinator.swift
//  NewsApp
//
//  Created by Egor on 14.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class CategoryCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    let category: ArticleCategory
    
    init(navigationController: UINavigationController, category: ArticleCategory) {
        self.navigationController = navigationController
        self.category = category
    }
    
    override func start() -> Observable<Void> {
        let viewModel = CategoryViewModel(category: category)
        let viewController = CategoryView(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.selectedArticleSubject
            .map { URL(string: $0.url) }
            .filter { $0 != nil }
            .flatMap { [unowned self] url -> Observable<Void> in
                let coordinator = WebCoordinator(navigationController: self.navigationController, url: url!)
                
                return self.coordinate(to: coordinator)
            }.subscribe()
            .disposed(by: disposeBag)
        
        let didClose = viewModel.closeSubject
        
        return didClose
            .take(1)
    }
}
