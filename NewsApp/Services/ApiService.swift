//
//  ApiService.swift
//  NewsApp
//
//  Created by Egor on 07.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import ObjectMapper

protocol ApiServiceProtocol {
    func getTopHeadlines() -> Observable<ArticlesObject>
    func getSources() -> Observable<SourcesObject>
    func getCategoryArticles(category: String) -> Observable<ArticlesObject>
    func getSourceArticles(source: String) -> Observable<ArticlesObject>
}

class ApiService: BaseApiService, ApiServiceProtocol {
    
    private let apiKey: String = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return "" }
        
        return (NSDictionary(contentsOfFile: path)?["APIKey"] as? String) ?? ""
    }()
    
    func getTopHeadlines() -> Observable<ArticlesObject> {
        let request = APIRequest(path: baseURL + "/top-headlines", parameters: ["apiKey": apiKey, "language": "en"], encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }

    func getSources() -> Observable<SourcesObject> {
        let request = APIRequest(path: baseURL + "/sources", parameters: ["apiKey": apiKey, "language": "en"], encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }

    func getCategoryArticles(category: String) -> Observable<ArticlesObject> {
        let request = APIRequest(path: baseURL + "/top-headlines", parameters: ["apiKey": apiKey, "language": "en", "category": category], encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
    
    /// Sends GET request to news api from given source
    /// - Parameter source: source id
    /// - Returns: Observable of the returned object
    func getSourceArticles(source: String) -> Observable<ArticlesObject> {
        let request = APIRequest(path: baseURL + "/everything", parameters: ["apiKey": apiKey, "language": "en", "sources": source], encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
}

class BaseApiService {
    fileprivate let baseURL = "https://newsapi.org/v2"
    
    fileprivate func callAPIRequest<T: BaseMappable>(request: APIRequest) -> Observable<T> {
        RxAlamofire.requestJSON(request.method, request.path, parameters: request.parameters, encoding: request.encoding, headers: request.headers)
            .flatMap { (_, json) -> Observable<T> in
                guard let json = json as? [String: Any] else { throw ApiError.noData }
                guard let model = Mapper<T>().map(JSON: json) else { throw ApiError.convertError }
                
                return .just(model)
            }
    }
}
