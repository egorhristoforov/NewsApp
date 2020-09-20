//
//  SourceViewModel.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

class SourceViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let apiService = ApiService()
    private let database = DatabaseManager.instance
    
    let source: Source
    
    // MARK: - Inputs
    
    let input: Input
    
    struct Input {
        let refresh: AnyObserver<Void>
        let close: AnyObserver<Void>
        let selectedArticle: AnyObserver<Article>
        let changeFavoriteStatus: AnyObserver<Article>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let changeFavoriteStatusSubject = PublishSubject<Article>()
    
    let closeSubject = PublishSubject<Void>()
    let selectedArticleSubject = PublishSubject<Article>()
    
    // MARK: - Outputs
    
    let output: Output
    
    struct Output {
        let refreshing: Driver<Bool>
        let articles: Driver<[Article]>
        let isArticlesLoading: Driver<Bool>
        let isEmptyArticlesList: Driver<Bool>
        
        let isArticlesLoadingError: Driver<Bool>
    }
    
    private let articlesSubject = BehaviorRelay<[Article]>(value: [])
    private let isArticlesLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isArticlesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    
    private let isArticlesLoadingErrorSubject = BehaviorSubject<Bool>(value: true)
    
    init(source: Source) {
        self.source = source
        
        input = Input(refresh: refreshSubject.asObserver(),
                      close: closeSubject.asObserver(),
                      selectedArticle: selectedArticleSubject.asObserver(),
                      changeFavoriteStatus: changeFavoriteStatusSubject.asObserver())
        
        let refreshing = isArticlesRefreshingSubject
            .asDriver(onErrorJustReturn: false)
        
        let articles = articlesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isArticlesLoading = isArticlesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isEmptyArticlesList = articlesSubject
            .withLatestFrom(isArticlesLoadingSubject) { !$1 && $0.count == 0 }
            .asDriver(onErrorJustReturn: false)
        
        let isArticlesLoadingError = Observable.combineLatest(isArticlesLoadingSubject, isArticlesRefreshingSubject, isArticlesLoadingErrorSubject)
            .map { !$0 && !$1 && $2 }
            .asDriver(onErrorJustReturn: false)
        
        output = Output(refreshing: refreshing,
                        articles: articles,
                        isArticlesLoading: isArticlesLoading,
                        isEmptyArticlesList: isEmptyArticlesList,
                        isArticlesLoadingError: isArticlesLoadingError)
        
        refreshSubject.subscribe(onNext: { [unowned self] _ in
            self.isArticlesRefreshingSubject.onNext(true)
            
            self.refreshAllData()
        }).disposed(by: disposeBag)
        
        database.favoriteChanges
            .subscribe(onNext: { [unowned self] change in
                switch change {
                case .deleted(let article), .inserted(let article):
                    var value = self.articlesSubject.value
                    guard let index = value.firstIndex(where: { $0 == article }) else { return }
                    value[index].isFavorite = !value[index].isFavorite
                    
                    self.articlesSubject.accept(value)
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

private extension SourceViewModel {
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
    
    func getArticles(completion: (() -> Void)? = nil) {
        apiService.getSourceArticles(source: source.id)
            .flatMap { [unowned self] articlesObject in
                self.prepareArticles(from: articlesObject)
            }.do(onNext: { _ in
                completion?()
            }, onError: { [unowned self] error in
                self.isArticlesLoadingErrorSubject.onNext(true)
            }).bind(to: articlesSubject)
            .disposed(by: disposeBag)
    }
    
    func getAllData() {
        isArticlesLoadingSubject.onNext(true)
        
        getArticles() { [weak self] in
            self?.isArticlesLoadingSubject.onNext(false)
        }
    }
    
    func refreshAllData() {
        isArticlesRefreshingSubject.onNext(true)
        
        getArticles() { [weak self] in
            self?.isArticlesRefreshingSubject.onNext(false)
        }
    }
}
