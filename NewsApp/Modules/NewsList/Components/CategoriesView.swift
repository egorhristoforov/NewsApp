//
//  CategoriesCollectionView.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa

class CategoriesView: UIView {
    private let categories: Driver<[ArticleCategory]>
    private let isLoading: Driver<Bool>
    private let selectedCategory: AnyObserver<ArticleCategory>
    private let isEmptyCategories: Driver<Bool>
    
    private let disposeBag = DisposeBag()
    
    private let cellId = "categoriesCellId"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        
        return label
    }()
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "Empty categories list", description: "An empty list of categories was received. Perhaps the categories will appear later.")
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    init(categories: Driver<[ArticleCategory]>, isLoading: Driver<Bool>,
         selectedCategory: AnyObserver<ArticleCategory>, isEmptyCategories: Driver<Bool>,
         title: String) {
        
        self.categories = categories
        self.isLoading = isLoading
        self.selectedCategory = selectedCategory
        self.isEmptyCategories = isEmptyCategories
        
        super.init(frame: .zero)
        
        categoriesCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        titleLabel.text = title
        
        setupViews()
        setupLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(categoriesCollectionView)
        addSubview(emptyStateModalView)
        addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16).labeled("titleLeading")
            make.trailing.equalToSuperview().offset(-16).labeled("titleTrailing")
            make.top.equalToSuperview().labeled("titleTop")
        }

        categoriesCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(54)
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        emptyStateModalView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupBindings() {        
        categories.drive(categoriesCollectionView.rx.items) { [unowned self] collectionView, index, category in
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            cell.category = category
            
            return cell
        }.disposed(by: disposeBag)
        
        isLoading.drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        categoriesCollectionView.rx.modelSelected(ArticleCategory.self)
            .bind(to: selectedCategory)
            .disposed(by: disposeBag)
        
        isEmptyCategories
            .map { !$0 }
            .drive(emptyStateModalView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
}
