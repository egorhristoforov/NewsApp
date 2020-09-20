//
//  NewsListViewModel.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa

class NewsListViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let apiService = ApiService()
    private let database = DatabaseManager.instance
    
    // MARK: - Inputs
    let input: Input
    
    struct Input {
        let refresh: AnyObserver<Void>
        let changeFavoriteStatus: AnyObserver<Article>
        
        let selectedArticle: AnyObserver<Article>
        let selectedSource: AnyObserver<Source>
        let selectedCategory: AnyObserver<ArticleCategory>
        
        let retryHeadlines: AnyObserver<Void>
        let retrySourcesAndCategories: AnyObserver<Void>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let changeFavoriteStatusSubject = PublishSubject<Article>()
    private let retryHeadlinesSubject = PublishSubject<Void>()
    private let retrySourcesAndCategoriesSubject = PublishSubject<Void>()
    
    let selectedArticleSubject = PublishSubject<Article>()
    let selectedSourceSubject = PublishSubject<Source>()
    let selectedCategorySubject = PublishSubject<ArticleCategory>()
    
    // MARK: - Outputs
    let output: Output
    
    struct Output {
        let refreshing: Driver<Bool>
        
        let headlines: Driver<[Article]>
        let sources: Driver<[Source]>
        let categories: Driver<[ArticleCategory]>
        
        let isHeadlinesLoading: Driver<Bool>
        let isSourcesLoading: Driver<Bool>
        let isCategoriesLoading: Driver<Bool>
        
        let isEmptyHeadlines: Driver<Bool>
        let isEmptySources: Driver<Bool>
        let isEmptyCategories: Driver<Bool>
        
        let isHeadlinesLoadingError: Driver<Bool>
        let isSourcesLoadingError: Driver<Bool>
    }
    
    private let headlinesSubject = BehaviorSubject<[Article]>(value: [])
    private let sourcesSubject = BehaviorSubject<[Source]>(value: [])
    private let categoriesSubject = BehaviorSubject<[ArticleCategory]>(value: [])
    
    private let isHeadlinesLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isSourcesLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isCategoriesLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    private let isHeadlinesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    private let isSourcesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    private let isCategoriesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    
    private let isHeadlinesLoadingErrorSubject = BehaviorSubject<Bool>(value: false)
    private let isSourcesLoadingErrorSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        input = Input(refresh: refreshSubject.asObserver(),
                      changeFavoriteStatus: changeFavoriteStatusSubject.asObserver(),
                      selectedArticle: selectedArticleSubject.asObserver(),
                      selectedSource: selectedSourceSubject.asObserver(),
                      selectedCategory: selectedCategorySubject.asObserver(),
                      retryHeadlines: retryHeadlinesSubject.asObserver(),
                      retrySourcesAndCategories: retrySourcesAndCategoriesSubject.asObserver())
        
        let refreshing = Observable.combineLatest(isHeadlinesRefreshingSubject, isCategoriesRefreshingSubject, isSourcesRefreshingSubject)
            .map({ $0 || $1 || $2 })
            .asDriver(onErrorJustReturn: false)
        
        let headlines = headlinesSubject
            .asDriver(onErrorJustReturn: [])
        
        let sources = sourcesSubject
            .asDriver(onErrorJustReturn: [])
        
        let categories = categoriesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isHeadlinesLoading = isHeadlinesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isSourcesLoading = isSourcesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isCategoriesLoading = isCategoriesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isEmptyHeadlines = Observable.combineLatest(headlinesSubject, isHeadlinesLoadingSubject, isHeadlinesLoadingErrorSubject)
            .map { !$1 && !$2 && $0.count == 0 }
            .asDriver(onErrorJustReturn: false)
        
        let isEmptySources = Observable.combineLatest(sourcesSubject, isSourcesLoadingSubject, isSourcesLoadingErrorSubject)
                .map { !$1 && !$2 && $0.count == 0 }
            .asDriver(onErrorJustReturn: false)
        
        let isEmptyCategories = Observable.combineLatest(categoriesSubject, isCategoriesLoadingSubject, isSourcesLoadingErrorSubject)
            .map { !$1 && !$2 && $0.count == 0 }
            .asDriver(onErrorJustReturn: false)
        
        let isHeadlinesLoadingError = Observable.combineLatest(isHeadlinesLoadingSubject, isHeadlinesRefreshingSubject, isHeadlinesLoadingErrorSubject)
            .map { !$0 && !$1 && $2 }
            .asDriver(onErrorJustReturn: false)
        
        let isSourcesLoadingError = Observable.combineLatest(isSourcesLoadingSubject, isSourcesRefreshingSubject, isSourcesLoadingErrorSubject)
            .map { !$0 && !$1 && $2 }
            .asDriver(onErrorJustReturn: false)
        
        output = Output(refreshing: refreshing,
                        headlines: headlines,
                        sources: sources,
                        categories: categories,
                        isHeadlinesLoading: isHeadlinesLoading,
                        isSourcesLoading: isSourcesLoading,
                        isCategoriesLoading: isCategoriesLoading,
                        isEmptyHeadlines: isEmptyHeadlines,
                        isEmptySources: isEmptySources,
                        isEmptyCategories: isEmptyCategories,
                        isHeadlinesLoadingError: isHeadlinesLoadingError,
                        isSourcesLoadingError: isSourcesLoadingError)
        
        refreshSubject.subscribe(onNext: { [unowned self] _ in
            self.isHeadlinesRefreshingSubject.onNext(true)
            self.isSourcesRefreshingSubject.onNext(true)
            self.isCategoriesRefreshingSubject.onNext(true)
            
            self.refreshAllData()
        }).disposed(by: disposeBag)
        
        retryHeadlinesSubject.subscribe(onNext: { [unowned self] _ in
            self.retryHeadlines()
        }).disposed(by: disposeBag)
        
        retrySourcesAndCategoriesSubject.subscribe(onNext: { [unowned self] _ in
            self.retrySourcesAndCategories()
        }).disposed(by: disposeBag)
        
        database.favoriteChanges
            .subscribe(onNext: { [unowned self] change in
                switch change {
                case .deleted(let article), .inserted(let article):
                    guard var value = try? self.headlinesSubject.value() else { return }
                    guard let index = value.firstIndex(where: { $0 == article }) else { return }
                    value[index].isFavorite = !value[index].isFavorite
                    
                    self.headlinesSubject.onNext(value)
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
        
        getAllData()
    }
}

private extension NewsListViewModel {
    func prepareHeadlines(from object: ArticlesObject) -> Observable<[Article]> {
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
    
    func prepareSources(from object: SourcesObject) -> Observable<[Source]> {
        return .just(object.sources.map({ Source(from: $0) }))
    }
    
    func parseCategories(from sources: [Source]) -> [ArticleCategory] {
        return sources.map({ $0.category })
            .unique()
            .map({ ArticleCategory(name: $0.capitalized) })
    }
    
    private func getAllData() {
        isHeadlinesLoadingSubject.onNext(true)
        isCategoriesLoadingSubject.onNext(true)
        isSourcesLoadingSubject.onNext(true)
        
        getHeadlines() { [weak self] in
            self?.isHeadlinesLoadingSubject.onNext(false)
        }
        
        getSourcesAndCategories() { [weak self] in
            self?.isSourcesLoadingSubject.onNext(false)
            self?.isCategoriesLoadingSubject.onNext(false)
        }
    }
    
    func getHeadlines(completion: (() -> Void)? = nil) {
        apiService.getTopHeadlines()
            .flatMap { [unowned self] articlesObject -> Observable<[Article]> in
                guard articlesObject.status == "ok" else { throw ApiError.unknown }
                
                return self.prepareHeadlines(from: articlesObject)
            }.subscribe(onNext: { [unowned self] articles in
                self.headlinesSubject.onNext(articles)
                completion?()
            }, onError: { error in
                self.isHeadlinesLoadingErrorSubject.onNext(true)
                completion?()
            })
            .disposed(by: disposeBag)
    }
    
    func getSourcesAndCategories(completion: (() -> Void)? = nil) {
        apiService.getSources()
            .flatMap { [unowned self] sourcesObject -> Observable<[Source]> in
                guard sourcesObject.status == "ok" else { throw ApiError.unknown }
                
                return self.prepareSources(from: sourcesObject)
            }.do(onNext: { [unowned self] (sources) in
                let categories = self.parseCategories(from: sources)
                self.categoriesSubject.onNext(categories)
            }).subscribe(onNext: { [unowned self] sources in
                self.sourcesSubject.onNext(sources)
                completion?()
            }, onError: { error in
                self.isSourcesLoadingErrorSubject.onNext(true)
                completion?()
            }).disposed(by: disposeBag)
    }
    
    private func refreshAllData() {
        isHeadlinesRefreshingSubject.onNext(true)
        isCategoriesRefreshingSubject.onNext(true)
        isSourcesRefreshingSubject.onNext(true)
        
        getHeadlines() { [weak self] in
            self?.isHeadlinesRefreshingSubject.onNext(false)
        }
        
        getSourcesAndCategories() { [weak self] in
            self?.isSourcesRefreshingSubject.onNext(false)
            self?.isCategoriesRefreshingSubject.onNext(false)
        }
    }
    
    private func retryHeadlines() {
        isHeadlinesLoadingSubject.onNext(true)
        
        getHeadlines() { [weak self] in
            self?.isHeadlinesLoadingSubject.onNext(false)
        }
    }
    
    private func retrySourcesAndCategories() {
        isCategoriesLoadingSubject.onNext(true)
        isSourcesLoadingSubject.onNext(true)
        
        getSourcesAndCategories() { [weak self] in
            self?.isSourcesLoadingSubject.onNext(false)
            self?.isCategoriesLoadingSubject.onNext(false)
        }
    }
}
