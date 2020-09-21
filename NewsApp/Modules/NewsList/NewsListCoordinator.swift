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
        
        viewModel.selectedArticleSubject
            .map { URL(string: $0.url) }
            .filter { $0 != nil }
            .flatMap { [unowned self] url -> Observable<Void> in
                let coordinator = WebCoordinator(navigationController: self.navigationController, url: url!)
                return self.coordinate(to: coordinator)
            }.subscribe()
            .disposed(by: disposeBag)
        
        viewModel.selectedCategorySubject
            .flatMap { [unowned self] category -> Observable<Void> in
                let coordinator = CategoryCoordinator(navigationController: self.navigationController, category: category)
                return self.coordinate(to: coordinator)
            }.subscribe()
            .disposed(by: disposeBag)
        
        viewModel.selectedSourceSubject
            .flatMap { [unowned self] source -> Observable<Void> in
                let coordinator = SourceCoordinator(navigationController: self.navigationController, source: source)
                return self.coordinate(to: coordinator)
            }.subscribe()
            .disposed(by: disposeBag)
        
        return Observable.never()
    }
}
