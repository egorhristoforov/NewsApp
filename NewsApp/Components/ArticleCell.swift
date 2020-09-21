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
    
    let favoriteButton: UIButton = {
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
            make.top.equalToSuperview().offset(LayoutConstants.cellVerticalPadding)
            make.leading.equalToSuperview().offset(LayoutConstants.cellHorizontalPadding)
            make.trailing.equalToSuperview().offset(-LayoutConstants.cellHorizontalPadding)
            make.bottom.equalToSuperview().offset(-LayoutConstants.cellVerticalPadding)
        }
        
        articleImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(LayoutConstants.imageHeight)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(articleImageView.snp.bottom).offset(LayoutConstants.titleMarginTop)
            make.leading.equalToSuperview().offset(LayoutConstants.titleMarginHorizontal)
            make.trailing.equalToSuperview().offset(-LayoutConstants.titleMarginHorizontal)
        }
        
        sourceLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(LayoutConstants.sourceMarginHorizontal)
            make.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.sourceMarginTop)
            make.bottom.equalToSuperview().offset(-LayoutConstants.sourceMarginBottom)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalTo(sourceLabel)
            make.trailing.equalToSuperview().offset(-LayoutConstants.sourceMarginHorizontal)
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.size.equalTo(LayoutConstants.favoriteButtonSize)
            make.top.equalToSuperview().offset(LayoutConstants.favoriteButtonMarginTop)
            make.trailing.equalToSuperview().offset(-LayoutConstants.favoriteButtonMarginTrailing)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        articleImageView.kf.cancelDownloadTask()
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
            articleImageView.kf.setImage(with: URL(string: url), completionHandler:  { [weak self] result in
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
            })
        } else {
            articleImageView.image = UIImage(named: "placeholder")
        }
    }
    
    deinit {
        print("deinit cell", self)
    }

}

private extension ArticleCell {
    enum LayoutConstants {
        static let cellHorizontalPadding = 16
        static let cellVerticalPadding = 10
        
        static let imageHeight = 144
        
        static let titleMarginTop = 10
        static let titleMarginHorizontal = 10
        
        static let sourceMarginTop = 22
        static let sourceMarginBottom = 10
        static let sourceMarginHorizontal = 10
        
        static let favoriteButtonSize = 40
        static let favoriteButtonMarginTop = 10
        static let favoriteButtonMarginTrailing = 10
    }
}
