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
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "No favorite articles", description: "You can add articles to favorites from news list screen.")
        
        return view
    }()
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Favorites"
        tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Bookmarks-tab"), tag: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
        tableView.register(ArticleCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = nil
        tableView.delegate = nil
        
        setupViews()
        setupLayout()
        setupBindings()
    }
    
    private func setupViews() {
        view.addSubview(emptyStateModalView)
    }
    
    private func setupLayout() {
        emptyStateModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
    }
    
    private func setupBindings() {
        viewModel.output.articles.drive(tableView.rx.items) { [unowned self] tableView, index, article in
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
    }

}
