//
//  SourceView.swift
//  NewsApp
//
//  Created by Egor on 15.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift

class SourceView: UITableViewController {
    
    private let viewModel: SourceViewModel
    private let disposeBag = DisposeBag()
    
    private let cellId = "articleCellId"
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "Empty news list", description: "An empty list of news was received. Perhaps the news will appear later.")
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.input.close.onNext(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = viewModel.source.name
        
        tableView.separatorStyle = .none
        tableView.register(ArticleCell.self, forCellReuseIdentifier: cellId)
        tableView.refreshControl = UIRefreshControl()
        tableView.dataSource = nil
        tableView.delegate = nil
        
        setupViews()
        setupLayout()
        setupBindings()
    }
    
    init(viewModel: SourceViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        view.addSubview(emptyStateModalView)
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        emptyStateModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
    }
    
    private func setupBindings() {
        viewModel.output.articles
            .drive(tableView.rx.items) { [unowned self] tableView, index, article in
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as? ArticleCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                
                cell.setupCell(article: article)

                cell.favoriteButtonTap
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
