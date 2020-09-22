//
//  MainCoordinator.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class MainCoordinator: Coordinator<Void> {
    let viewController: MainView

    init(viewController: MainView) {
        self.viewController = viewController
    }
    
    override func start() -> Observable<Void> {
        
        let newsListNavigationController = UINavigationController()
        let newsListCoordinator = NewsListCoordinator(navigationController: newsListNavigationController)
        
        let favoritesNavigationController = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNavigationController)
        
        let searchNavigationController = UINavigationController()
        let searchCoordinator = SearchCoordinator(navigationController: searchNavigationController)
        
        coordinate(to: searchCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        coordinate(to: newsListCoordinator)
            .subscribe()
            .disposed(by: disposeBag)

        coordinate(to: favoritesCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        viewController.viewControllers = [searchNavigationController, newsListNavigationController, favoritesNavigationController]
        viewController.selectedIndex = 1
        
        return Observable.never()
    }
}
