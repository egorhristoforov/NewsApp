//
//  NewsListView.swift
//  NewsApp
//
//  Created by Egor on 12.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class NewsListView: UITableViewController {
    
    private let viewModel: NewsListViewModel
    private let disposeBag = DisposeBag()
    
    private let headlineCellId = "headlineCellId"
    
    private lazy var categoriesCollectionView: CategoriesView = {
        let view = CategoriesView(categories: viewModel.output.categories,
                                  isLoading: viewModel.output.isCategoriesLoading,
                                  selectedCategory: viewModel.input.selectedCategory,
                                  isEmptyCategories: viewModel.output.isEmptyCategories,
                                  title: "Categories")
        
        return view
    }()
    
    private lazy var sourcesCollectionView: SourcesView = {
        let view = SourcesView(sources: viewModel.output.sources,
                               isLoading: viewModel.output.isSourcesLoading,
                               selectedSource: viewModel.input.selectedSource,
                               isEmptySources: viewModel.output.isEmptySources,
                               title: "Sources")
        
        return view
    }()
    
    private let headlinesTableViewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.text = "Top headlines 🔥"
        
        return label
    }()
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "Empty news list", description: "An empty list of news was received. Perhaps the news will appear later.")
        
        return view
    }()
    
    private let sourcesErrorModalView: ModalView = {
        let view = ModalView(title: "Sources and categories error", description: "An error was recieved. Try again later.", buttonText: "Retry")
        
        return view
    }()
    
    private let headlinesErrorModalView: ModalView = {
        let view = ModalView(title: "Headlines error", description: "An error was recieved. Try again later.", buttonText: "Retry")
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    private let tableHeaderView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "News"
        tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Today-tab"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(ArticleCell.self, forCellReuseIdentifier: headlineCellId)
        tableView.tableHeaderView = tableHeaderView
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        setupViews()
        setupLayout()
        setupBindings()
    }
    
    private func setupViews() {
        tableHeaderView.addSubview(categoriesCollectionView)
        tableHeaderView.addSubview(sourcesCollectionView)
        tableHeaderView.addSubview(headlinesTableViewTitleLabel)
        tableHeaderView.addSubview(sourcesErrorModalView)
        
        view.addSubview(emptyStateModalView)
        view.addSubview(headlinesErrorModalView)
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        categoriesCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        sourcesCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(categoriesCollectionView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
        }
        
        headlinesTableViewTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(sourcesCollectionView.snp.bottom).offset(15)
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        emptyStateModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        headlinesErrorModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        sourcesErrorModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.output.headlines
            .drive(tableView.rx.items) { [unowned self] tableView, index, article in
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.headlineCellId, for: indexPath) as? ArticleCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                
                cell.setupCell(article: article)
                
                cell.favoriteButtonTap
                    .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
                    .map({ _ in return article })
                    .bind(to: self.viewModel.input.changeFavoriteStatus)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }.disposed(by: disposeBag)
        
        viewModel.output.isHeadlinesLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.isEmptyHeadlines
            .map { !$0 }
            .drive(emptyStateModalView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Article.self)
            .bind(to: viewModel.input.selectedArticle)
            .disposed(by: disposeBag)
        
        viewModel.output.isHeadlinesLoadingError
            .map { !$0 }
            .drive(headlinesErrorModalView.rx.isHidden)
            .disposed(by: disposeBag)
        
        headlinesErrorModalView.button.rx.tap
            .bind(to: viewModel.input.retryHeadlines)
            .disposed(by: disposeBag)
        
        viewModel.output.isSourcesLoadingError
            .map { !$0 }
            .drive(sourcesErrorModalView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.isSourcesLoadingError
            .drive(categoriesCollectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.isSourcesLoadingError
            .drive(sourcesCollectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        sourcesErrorModalView.button.rx.tap
            .bind(to: viewModel.input.retrySourcesAndCategories)
            .disposed(by: disposeBag)
        
        if let refreshControl = refreshControl {
            viewModel.output.refreshing
                .drive(refreshControl.rx.isRefreshing)
                .disposed(by: disposeBag)
            
            refreshControl.rx.controlEvent(.valueChanged)
                .bind(to: viewModel.input.refresh)
                .disposed(by: disposeBag)
        }
    }
}
