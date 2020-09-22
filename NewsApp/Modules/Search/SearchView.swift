//
//  SearchView.swift
//  NewsApp
//
//  Created by Egor on 22.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class SearchView: UITableViewController {

    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    private let cellId = "articleCellId"
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "Empty news list", description: "An empty list of news was received. Perhaps the news will appear later.")
        
        return view
    }()
    
    private let errorModalView: ModalView = {
        let view = ModalView(title: "Search error", description: "An error was recieved. Try again later.", buttonText: "Retry")
        
        return view
    }()
    
    private let customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        return refreshControl
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Search"
        tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Search-tab"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        tableView.separatorStyle = .none
        tableView.register(ArticleCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = nil
        tableView.delegate = nil
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        setupViews()
        setupLayout()
        setupBindings()
    }
    
    private func setupViews() {
        tableView.addSubview(customRefreshControl)
        view.addSubview(emptyStateModalView)
        view.addSubview(errorModalView)
    }
    
    private func setupLayout() {
        emptyStateModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-LayoutConstants.modalViewMarginHorizontal)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(LayoutConstants.modalViewMarginTop)
        }
        
        errorModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-LayoutConstants.modalViewMarginHorizontal)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(LayoutConstants.modalViewMarginTop)
        }
    }
    
    private func setupBindings() {
        viewModel.output.articles.drive(tableView.rx.items) { [unowned self] tableView, index, article in
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as? ArticleCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            cell.setupCell(article: article)
            
            cell.favoriteButton.rx.tap
                .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
                .map({ _ in return article })
                .bind(to: self.viewModel.input.changeFavoriteStatus)
                .disposed(by: cell.disposeBag)
            
            return cell
        }.disposed(by: disposeBag)
        
        viewModel.output.isArticlesLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Article.self)
            .bind(to: viewModel.input.selectedArticle)
            .disposed(by: disposeBag)
        
        viewModel.output.isEmptyArticlesList
            .map { !$0 }
            .drive(emptyStateModalView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.isArticlesLoadingError
            .map { !$0 }
            .drive(errorModalView.rx.isHidden)
            .disposed(by: disposeBag)
        
        errorModalView.button.rx.tap
            .bind(to: viewModel.input.retry)
            .disposed(by: disposeBag)
        
        viewModel.output.refreshing
            .debug()
            .drive(customRefreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        customRefreshControl.rx.controlEvent(.valueChanged)
            .debug()
            .bind(to: viewModel.input.refresh)
            .disposed(by: disposeBag)
        
        let cancelSearch = searchController.searchBar.rx.cancelButtonClicked.map { _ in "" }
        let searchTextChange = searchController.searchBar.rx.text.orEmpty.asObservable()

        Observable.of(cancelSearch, searchTextChange)
            .merge()
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.input.searchText)
            .disposed(by: disposeBag)
        
        tableView.rx.willBeginDragging.subscribe { [unowned self] _ in
            searchController.searchBar.endEditing(true)
        }.disposed(by: disposeBag)
    }
}

private extension SearchView {
    enum LayoutConstants {
        static let modalViewMarginTop = 20
        static let modalViewMarginHorizontal = 40
    }
}
