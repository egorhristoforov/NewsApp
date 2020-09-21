//
//  CategoryCollectionViewCell.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    var category: ArticleCategory? {
        didSet {
            nameLabel.text = category?.name
            categoryImageView.image = category?.image
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        
        return label
    }()
    
    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
        
        backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(nameLabel)
    }
    
    private func setupLayout() {
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LayoutConstants.nameLabelMarginVertical)
            make.bottom.equalToSuperview().offset(-LayoutConstants.nameLabelMarginVertical)
            make.leading.equalToSuperview().offset(LayoutConstants.nameLabelMarginHorizontal)
            make.trailing.equalToSuperview().offset(-LayoutConstants.nameLabelMarginHorizontal)
        }
        
        categoryImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LayoutConstants.categoryImageMarginVertical)
            make.bottom.equalToSuperview().offset(-LayoutConstants.categoryImageMarginVertical)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

private extension CategoryCollectionViewCell {
    enum LayoutConstants {
        static let nameLabelMarginHorizontal = 20
        static let nameLabelMarginVertical = 17
        
        static let categoryImageMarginVertical = 8
    }
}
