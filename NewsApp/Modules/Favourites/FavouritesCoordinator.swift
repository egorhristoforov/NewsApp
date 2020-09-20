//
//  FavouritesCoordinator.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class FavouritesCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FavoritesViewModel()
        let viewController = FavoritesView(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: false)
        
        viewModel.selectedArticle.subscribe(onNext: { [unowned self] (article) in
            guard let url = URL(string: article.url) else { return }
            let coordinator = WebCoordinator(navigationController: self.navigationController, url: url)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
}
