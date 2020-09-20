//
//  ArticleCell.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher

class ArticleCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    let favoriteButtonTap = PublishSubject<Void>()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        view.layer.cornerRadius = 10
        
        return view
    }()

    private let articleImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.kf.indicatorType = .activity
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        label.textAlignment = .right
        
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        wrapperView.addSubview(articleImageView)
        wrapperView.addSubview(titleLabel)
        wrapperView.addSubview(sourceLabel)
        wrapperView.addSubview(dateLabel)
        
        wrapperView.addSubview(favoriteButton)
        
        contentView.addSubview(wrapperView)
    }
    
    private func setupLayout() {
        wrapperView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        articleImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(144)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(articleImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        sourceLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(22)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalTo(sourceLabel)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        articleImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        sourceLabel.text = nil
        
        favoriteButton.setImage(UIImage(named: "not-favorite"), for: .normal)
        
        disposeBag = DisposeBag()
    }
    
    func setupCell(article: Article) {
        titleLabel.text = article.title
        sourceLabel.text = article.sourceName
        dateLabel.text = article.publishedAt?.toString()
        
        favoriteButton.setImage(article.isFavorite ? UIImage(named: "favorite") : UIImage(named: "not-favorite"), for: .normal)
        
        if let url = article.urlToImage {
            articleImageView.kf.setImage(with: URL(string: url)) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    switch error {
                    case .responseError(reason: _), .requestError(reason: _):
                        self?.articleImageView.image = UIImage(named: "placeholder")
                    default:
                        break
                    }
                }
            }
        } else {
            articleImageView.image = UIImage(named: "placeholder")
        }
        
        favoriteButton.rx.tap
            .bind(to: favoriteButtonTap)
            .disposed(by: disposeBag)
    }

}
