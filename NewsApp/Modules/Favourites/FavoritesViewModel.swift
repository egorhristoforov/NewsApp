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
        let searchText: AnyObserver<String>
    }
    
    let selectedArticle = PublishSubject<Article>()
    private let changeFavoriteStatus = PublishSubject<Article>()
    private let searchTextSubject = BehaviorSubject<String>(value: "")
    
    // MARK: - Outputs
    let output: Output
    
    struct Output {
        let articles: Driver<[Article]>
        let isArticlesLoading: Driver<Bool>
        let isEmptyArticlesList: Driver<Bool>
    }
    
    private let articlesSubject = BehaviorSubject<[Article]>(value: [])
    private let isArticlesLoadingSubject = BehaviorSubject<Bool>(value: true)
    
    init() {
        input = Input(changeFavoriteStatus: changeFavoriteStatus.asObserver(),
                      selectedArticle: selectedArticle.asObserver(),
                      searchText: searchTextSubject.asObserver())
        
        let articles = articlesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isArticlesLoading = isArticlesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isEmptyArticlesList = articlesSubject
            .map({ $0.count == 0 })
            .asDriver(onErrorJustReturn: false)
        
        output = Output(articles: articles,
                        isArticlesLoading: isArticlesLoading,
                        isEmptyArticlesList: isEmptyArticlesList)
        
        database.favoriteArticles
            .do { [unowned self] _ in
                isArticlesLoadingSubject.onNext(true)
            }.withLatestFrom(searchTextSubject) { ($0, $1) }
            .map { articles, query in
                if query.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return articles
                }
                
                return articles.filter { $0.title.lowercased().contains(query.lowercased()) }
            }.do { [unowned self] _ in
                isArticlesLoadingSubject.onNext(false)
            }.bind(to: articlesSubject)
            .disposed(by: disposeBag)
        
        changeFavoriteStatus
            .bind(to: database.removeFromFavorites)
            .disposed(by: disposeBag)
        
        searchTextSubject
            .do { [unowned self] _ in
                isArticlesLoadingSubject.onNext(true)
            }.withLatestFrom(database.favoriteArticles) { ($0, $1) }
            .map { query, articles in
                if query.isEmpty() {
                    return articles
                }
                
                return articles.filter { $0.title.lowercased().contains(query.lowercased()) }
            }.do { [unowned self] _ in
                isArticlesLoadingSubject.onNext(false)
            }.bind(to: articlesSubject)
            .disposed(by: disposeBag)
    }
}
