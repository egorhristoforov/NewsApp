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
        
        let favouritesNavigationController = UINavigationController()
        let favouritesCoordinator = FavoritesCoordinator(navigationController: favouritesNavigationController)
        
        coordinate(to: newsListCoordinator)
            .subscribe()
            .disposed(by: disposeBag)

        coordinate(to: favouritesCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        viewController.viewControllers = [newsListNavigationController, favouritesNavigationController]
        
        return Observable.never()
    }
}
