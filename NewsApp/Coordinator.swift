//
//  BaseCoordinator.swift
//  NewsApp
//
//  Created by Egor on 07.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

open class Coordinator<ResultType>: NSObject {

    public typealias CoordinationResult = ResultType

    public let disposeBag = DisposeBag()
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    private func store<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    private func release<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    @discardableResult
    open func coordinate<T>(to coordinator: Coordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in
                self?.release(coordinator: coordinator) })
    }

    open func start() -> Observable<ResultType> {
        fatalError("start() method must be implemented")
    }
}
