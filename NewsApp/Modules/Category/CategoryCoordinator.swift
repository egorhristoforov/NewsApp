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
        
        viewModel.selectedArticleSubject.subscribe(onNext: { [unowned self] (article) in
            guard let url = URL(string: article.url) else { return }
            let coordinator = WebCoordinator(navigationController: self.navigationController, url: url)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        return viewModel.closeSubject
            .take(1)
    }
}
