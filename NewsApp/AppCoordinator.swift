//
//  AppCoordinator.swift
//  NewsApp
//
//  Created by Egor on 07.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class AppCoordinator: Coordinator<Void> {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewController = MainView()
        let coordinator = MainCoordinator(viewController: viewController)

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        return coordinate(to: coordinator)
    }
}
