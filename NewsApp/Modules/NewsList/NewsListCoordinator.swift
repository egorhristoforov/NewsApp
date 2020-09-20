//
//  NewsListCoordinator.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class NewsListCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = NewsListViewModel()
        let viewController = NewsListView(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: false)
        
        viewModel.selectedArticleSubject.subscribe(onNext: { [unowned self] (article) in
            guard let url = URL(string: article.url) else { return }
            let coordinator = WebCoordinator(navigationController: self.navigationController, url: url)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        viewModel.selectedCategorySubject.subscribe(onNext: { [unowned self] (category) in
            let coordinator = CategoryCoordinator(navigationController: self.navigationController, category: category)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        viewModel.selectedSourceSubject.subscribe(onNext: { [unowned self] (source) in
            let coordinator = SourceCoordinator(navigationController: self.navigationController, source: source)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
}
