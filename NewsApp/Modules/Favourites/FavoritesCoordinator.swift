//
//  FavouritesCoordinator.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class FavoritesCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FavoritesViewModel()
        let viewController = FavoritesView(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: false)
        
        viewModel.selectedArticle
            .map { URL(string: $0.url) }
            .filter { $0 != nil }
            .flatMap { [unowned self] url -> Observable<Void> in
                let coordinator = WebCoordinator(navigationController: self.navigationController, url: url!)
                
                return self.coordinate(to: coordinator)
            }.subscribe()
            .disposed(by: disposeBag)
        
        return Observable.never()
    }
}
