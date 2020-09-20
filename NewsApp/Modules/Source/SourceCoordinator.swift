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
        
        viewModel.selectedArticleSubject.subscribe(onNext: { [unowned self] (article) in
            guard let url = URL(string: article.url) else { return }
            let coordinator = WebCoordinator(navigationController: self.navigationController, url: url)
            
            self.coordinate(to: coordinator)
        }).disposed(by: disposeBag)
        
        return viewModel.closeSubject
            .take(1)
    }
}
