//
//  SourceCoordinator.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class SourceCoordinator: Coordinator<Void> {
    let navigationController: UINavigationController
    let source: Source
    
    init(navigationController: UINavigationController, source: Source) {
        self.navigationController = navigationController
        self.source = source
    }
    
    override func start() -> Observable<Void> {
        let viewModel = SourceViewModel(source: source)
        let viewController = SourceView(viewModel: viewModel)
        
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
