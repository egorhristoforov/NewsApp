//
//  Database.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxRealm
import RxSwift
import RealmSwift

enum DatabaseChangeType<T> {
    case deleted(T)
    case inserted(T)
    case updated(T)
}

class DatabaseManager {
    private let realm = try! Realm()
    private let disposeBag = DisposeBag()
    
    private let realmFavoriteArticles: BehaviorSubject<Results<FavoriteArticle>>
    
    static let instance = DatabaseManager()
    
    let addToFavorites = PublishSubject<Article>()
    let removeFromFavorites = PublishSubject<Article>()
    let favoriteChanges = PublishSubject<DatabaseChangeType<Article>>()
    let favoriteArticles = BehaviorSubject<[Article]>(value: [])
    
    private init () {
        let realmObjects = realm.objects(FavoriteArticle.self)
        realmFavoriteArticles = BehaviorSubject<Results<FavoriteArticle>>(value: realmObjects)

        realmFavoriteArticles
            .map({ $0.map { Article(from: $0) } })
            .bind(to: favoriteArticles)
            .disposed(by: disposeBag)

        Observable.collection(from: realmObjects)
            .bind(to: realmFavoriteArticles)
            .disposed(by: disposeBag)

        addToFavorites
            .map({ ($0, FavoriteArticle(from: $0)) })
            .subscribe(onNext: { [unowned self] article, storedArticle in
                storedArticle.isFavorite = true
                try! self.realm.write {
                    self.realm.add(storedArticle)
                }

                self.favoriteChanges.onNext(.inserted(article))
            })
            .disposed(by: disposeBag)

        removeFromFavorites
            .withLatestFrom(realmFavoriteArticles) {
                return ($0, $1)
            }.map({ article, favoriteArticles in
                return (article, favoriteArticles.first(where: { $0 == article }))
            }).subscribe(onNext: { [unowned self] article, storedArticle in
                if let storedArticle = storedArticle {
                    try! self.realm.write {
                        self.realm.delete(storedArticle)
                    }

                    self.favoriteChanges.onNext(.deleted(article))
                }
            })
            .disposed(by: disposeBag)
    }
}
