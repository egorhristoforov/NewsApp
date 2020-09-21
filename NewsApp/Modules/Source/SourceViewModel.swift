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
        let retry: AnyObserver<Void>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let changeFavoriteStatusSubject = PublishSubject<Article>()
    private let retrySubject = PublishSubject<Void>()
    
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
    
    private let articlesSubject = BehaviorSubject<[Article]>(value: [])
    private let isArticlesLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isArticlesRefreshingSubject = BehaviorSubject<Bool>(value: false)
    
    private let isArticlesLoadingErrorSubject = BehaviorSubject<Bool>(value: false)
    
    init(source: Source) {
        self.source = source
        
        input = Input(refresh: refreshSubject.asObserver(),
                      close: closeSubject.asObserver(),
                      selectedArticle: selectedArticleSubject.asObserver(),
                      changeFavoriteStatus: changeFavoriteStatusSubject.asObserver(),
                      retry: retrySubject.asObserver())
        
        let refreshing = isArticlesRefreshingSubject
            .asDriver(onErrorJustReturn: false)
        
        let articles = articlesSubject
            .asDriver(onErrorJustReturn: [])
        
        let isArticlesLoading = isArticlesLoadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let isEmptyArticlesList = Observable.combineLatest(articlesSubject, isArticlesLoadingSubject, isArticlesLoadingErrorSubject)
            .map { !$1 && !$2 && $0.count == 0 }
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
            self.refreshAllData()
        }).disposed(by: disposeBag)
        
        retrySubject.subscribe(onNext: { [unowned self] _ in
            self.getAllData()
        }).disposed(by: disposeBag)
        
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
        apiService.getSourceArticles(source: source.id).take(1)
            .flatMap { [unowned self] articlesObject -> Observable<[Article]> in
                guard articlesObject.status == "ok" else { throw ApiError.unknown }

                return self.prepareArticles(from: articlesObject)
            }.subscribe(onNext: { [unowned self] articles in
                self.articlesSubject.onNext(articles)
                completion?()
            }, onError: { [unowned self] error in
                self.isArticlesLoadingErrorSubject.onNext(true)
                completion?()
            })
            .disposed(by: disposeBag)
    }
    
    func getAllData() {
        isArticlesLoadingSubject.onNext(true)
        
        getArticles() { [unowned self] in
            self.isArticlesLoadingSubject.onNext(false)
        }
    }
    
    func refreshAllData() {
        isArticlesRefreshingSubject.onNext(true)
        
        getArticles() { [unowned self] in
            self.isArticlesRefreshingSubject.onNext(false)
        }
    }
}
