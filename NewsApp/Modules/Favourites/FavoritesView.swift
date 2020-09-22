//
//  FavouritesView.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class FavoritesView: UITableViewController {
    
    private let viewModel: FavoritesViewModel
    private let disposeBag = DisposeBag()
    
    private let cellId = "articleCellId"
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "No favorite articles", description: "You can add articles to favorites from news list screen.")
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Favorites"
        tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Bookmarks-tab"), tag: 2)
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
        view.addSubview(emptyStateModalView)
    }
    
    private func setupLayout() {
        emptyStateModalView.snp.makeConstraints { (make) in
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
        
        tableView.rx.modelDeleted(Article.self)
            .bind(to: viewModel.input.changeFavoriteStatus)
            .disposed(by: disposeBag)
        
        viewModel.output.isEmptyArticlesList
            .map { !$0 }
            .drive(emptyStateModalView.rx.isHidden)
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

private extension FavoritesView {
    enum LayoutConstants {
        static let modalViewMarginTop = 20
        static let modalViewMarginHorizontal = 40
    }
}
