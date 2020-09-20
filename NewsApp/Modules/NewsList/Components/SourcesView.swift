//
//  SourcesView.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa

class SourcesView: UIView {
    private let sources: Driver<[Source]>
    private let isLoading: Driver<Bool>
    private let selectedSource: AnyObserver<Source>
    private let isEmptySources: Driver<Bool>
    
    private let disposeBag = DisposeBag()
    
    private let cellId = "sourcesCellId"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        
        return label
    }()
    
    private let sourcesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        
        layout.itemSize = CGSize(width: 200, height: 85)
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    private let emptyStateModalView: ModalView = {
        let view = ModalView(title: "Empty sources list", description: "An empty list of sources was received. Perhaps the sources will appear later.")
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        
        return view
    }()
    
    init(sources: Driver<[Source]>, isLoading: Driver<Bool>,
         selectedSource: AnyObserver<Source>, isEmptySources: Driver<Bool>,
         title: String) {
        
        self.sources = sources
        self.isLoading = isLoading
        self.selectedSource = selectedSource
        self.isEmptySources = isEmptySources
        
        super.init(frame: .zero)
        
        sourcesCollectionView.register(SourceCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
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
        addSubview(sourcesCollectionView)
        addSubview(emptyStateModalView)
        addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16).labeled("titleLeading")
            make.trailing.equalToSuperview().offset(-16).labeled("titleTrailing")
            make.top.equalToSuperview().labeled("titleTop")
        }
        
        sourcesCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(85)
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
        sources.drive(sourcesCollectionView.rx.items) { [unowned self] collectionView, index, source in
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as? SourceCollectionViewCell else { return UICollectionViewCell() }
            cell.source = source
            
            return cell
        }.disposed(by: disposeBag)
        
        isLoading.drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        sourcesCollectionView.rx.modelSelected(Source.self)
            .bind(to: selectedSource)
            .disposed(by: disposeBag)
        
        isEmptySources
            .map { !$0 }
            .drive(emptyStateModalView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
