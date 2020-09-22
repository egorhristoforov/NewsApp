//
//  SearchViewModel.swift
//  NewsApp
//
//  Created by Egor on 22.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let database = DatabaseManager.instance
    private let apiService = ApiService()
    
    // MARK: - Inputs
    let input: Input
    
    struct Input {
        let changeFavoriteStatus: AnyObserver<Article>
        let selectedArticle: AnyObserver<Article>
        let searchText: AnyObserver<String>
        let refresh: AnyObserver<Void>
        let retry: AnyObserver<Void>
    }
    
    let selectedArticle = PublishSubject<Article>()
    private let changeFavoriteStatusSubject = PublishSubject<Article>()
    private let searchTextSubject = PublishSubject<String>()
    private let refreshSubject = PublishSubject<Void>()
    private let retrySubject = PublishSubject<Void>()
    
    // MARK: - Outputs
    let output: Output
    
    struct Output {
        let refreshing: Driver<Bool>
        let articles: Driver<[Article]>
        let isArticlesLoading: Driver<Bool>
        let isEmptyArticlesList: Driver<Bool>
        let isArticlesLoadingError: Driver<Bool>
    }
    
    private let articlesSubject = BehaviorSubject<[Article]>(value: [])
    private let isArticlesLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isArticlesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    private let isArticlesLoadingErrorSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        input = Input(changeFavoriteStatus: changeFavoriteStatusSubject.asObserver(),
                      selectedArticle: selectedArticle.asObserver(),
                      searchText: searchTextSubject.asObserver(),
                      refresh: refreshSubject.asObserver(),
                      retry: retrySubject.asObserver())
        
        let articles = articlesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isArticlesLoading = isArticlesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let searchText = searchTextSubject.startWith("")
        
        let isEmptyArticlesList = Observable.combineLatest(articlesSubject, isArticlesLoadingSubject, isArticlesLoadingErrorSubject, searchText)
            .map { !$3.isEmpty() && !$1 && !$2 && $0.count == 0 }
            .asDriver(onErrorJustReturn: false)
        
        let refreshing = isArticlesRefreshingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isArticlesLoadingError = Observable.combineLatest(isArticlesLoadingSubject, isArticlesRefreshingSubject, isArticlesLoadingErrorSubject)
            .map { !$0 && !$1 && $2 }
            .asDriver(onErrorJustReturn: false)
        
        output = Output(refreshing: refreshing,
                        articles: articles,
                        isArticlesLoading: isArticlesLoading,
                        isEmptyArticlesList: isEmptyArticlesList,
                        isArticlesLoadingError: isArticlesLoadingError)
        
        database.favoriteChanges
            .subscribe(onNext: { [unowned self] change in
                switch change {
                case .deleted(let article), .inserted(let article):
                    guard var value = try? self.articlesSubject.value() else { return }
                    guard let index = value.firstIndex(where: { $0 == article }) else { return }
                    value[index].isFavorite = !value[index].isFavorite
                    
                    self.articlesSubject.onNext(value)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        changeFavoriteStatusSubject
            .subscribe(onNext: { [unowned self] article in
                if article.isFavorite {
                    self.database.removeFromFavorites.onNext(article)
                } else {
                    self.database.addToFavorites.onNext(article)
                }
            }).disposed(by: disposeBag)
        
        searchTextSubject
            .do(onNext: { [unowned self] query in
                if query.isEmpty() {
                    articlesSubject.onNext([])
                } else {
                    isArticlesLoadingSubject.onNext(true)
                }
            })
            .filter { !$0.isEmpty() }
            .flatMap { [unowned self] query in
                apiService.getArticlesBySearch(query: query)
                    .flatMap { articlesObject -> Observable<[Article]> in
                        guard articlesObject.status == "ok" else { throw ApiError.unknown }
                        return prepareArticles(from: articlesObject)
                    }
            }.subscribe { [unowned self] articles in
                articlesSubject.onNext(articles)
                isArticlesLoadingSubject.onNext(false)
            } onError: { [unowned self] error in
                isArticlesLoadingErrorSubject.onNext(true)
                isArticlesLoadingSubject.onNext(false)
            }.disposed(by: disposeBag)
        
        refreshSubject
            .withLatestFrom(searchTextSubject) { $1 }
            .do { [unowned self] query in
                if query.isEmpty() {
                    articlesSubject.onNext([])
                    isArticlesRefreshingSubject.onNext(false)
                } else {
                    isArticlesRefreshingSubject.onNext(true)
                }
            }.filter { !$0.isEmpty() }
            .flatMap { [unowned self] query in
                apiService.getArticlesBySearch(query: query)
                    .flatMap { articlesObject -> Observable<[Article]> in
                        guard articlesObject.status == "ok" else { throw ApiError.unknown }
                        return prepareArticles(from: articlesObject)
                    }
            }.subscribe { [unowned self] articles in
                articlesSubject.onNext(articles)
                isArticlesRefreshingSubject.onNext(false)
            } onError: { [unowned self] error in
                isArticlesLoadingErrorSubject.onNext(true)
                isArticlesRefreshingSubject.onNext(false)
            }.disposed(by: disposeBag)

        retrySubject
            .withLatestFrom(searchTextSubject) { $1 }
            .do { [unowned self] query in
                if query.isEmpty() {
                    articlesSubject.onNext([])
                } else {
                    isArticlesLoadingSubject.onNext(true)
                }
            }.filter { !$0.isEmpty() }
            .flatMap { [unowned self] query in
                apiService.getArticlesBySearch(query: query)
                    .flatMap { articlesObject -> Observable<[Article]> in
                        guard articlesObject.status == "ok" else { throw ApiError.unknown }
                        return prepareArticles(from: articlesObject)
                    }
            }.subscribe { [unowned self] articles in
                articlesSubject.onNext(articles)
                isArticlesLoadingSubject.onNext(false)
            } onError: { [unowned self] error in
                isArticlesLoadingErrorSubject.onNext(true)
                isArticlesLoadingSubject.onNext(false)
            }.disposed(by: disposeBag)
    }
}

private extension SearchViewModel {
    func prepareArticles(from object: ArticlesObject) -> Observable<[Article]> {
        return Observable.just(object.articles.map{ Article(from: $0) })
            .withLatestFrom(database.favoriteArticles) { ($0, $1) }
            .map { articles, favoriteArticles -> [Article] in
                articles.map { article in
                    var preparedArticle = article
                    preparedArticle.isFavorite = favoriteArticles.first(where: { (storedArticle) -> Bool in
                        storedArticle == article
                    }) != nil
                    return preparedArticle
                }
        }
    }
}
