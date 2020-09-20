//
//  FavouritesViewModel.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa

class FavoritesViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let database = DatabaseManager.instance
    
    // MARK: - Inputs
    let input: Input
    
    struct Input {
        let changeFavoriteStatus: AnyObserver<Article>
        let selectedArticle: AnyObserver<Article>
    }
    
    let selectedArticle = PublishSubject<Article>()
    private let changeFavoriteStatus = PublishSubject<Article>()
    
    // MARK: - Outputs
    let output: Output
    
    struct Output {
        let articles: Driver<[Article]>
        let isEmptyArticlesList: Driver<Bool>
    }
    
    private let articlesSubject = BehaviorSubject<[Article]>(value: [])
    
    init() {
        input = Input(changeFavoriteStatus: changeFavoriteStatus.asObserver(),
                      selectedArticle: selectedArticle.asObserver())
        
        let articles = articlesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isEmptyArticlesList = articlesSubject
            .map({ $0.count == 0 })
            .asDriver(onErrorJustReturn: false)
        
        output = Output(articles: articles,
                        isEmptyArticlesList: isEmptyArticlesList)
        
        database.favoriteArticles
            .bind(to: articlesSubject)
            .disposed(by: disposeBag)
        
        changeFavoriteStatus
            .bind(to: database.removeFromFavorites)
            .disposed(by: disposeBag)
    }
}
