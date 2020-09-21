//
//  SourceCollectionViewCell.swift
//  NewsApp
//
//  Created by Egor on 13.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit

class SourceCollectionViewCell: UICollectionViewCell {
    var source: Source? {
        didSet {
            titleLabel.text = source?.name
            descriptionLabel.text = source?.description
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        return label
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(LayoutConstants.titleMarginHorizontal)
            make.trailing.equalToSuperview().offset(-LayoutConstants.titleMarginHorizontal)
            make.top.equalToSuperview().offset(LayoutConstants.titleMarginTop)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.descriptionMarginTop)
            make.leading.equalToSuperview().offset(LayoutConstants.descriptionMarginHorizontal)
            make.trailing.equalToSuperview().offset(-LayoutConstants.descriptionMarginHorizontal)
            make.bottom.equalToSuperview().offset(-LayoutConstants.descriptionMarginBottom)
        }
    }
}

private extension SourceCollectionViewCell {
    enum LayoutConstants {
        static let titleMarginHorizontal = 15
        static let titleMarginTop = 10
        
        static let descriptionMarginHorizontal = 15
        static let descriptionMarginTop = 6
        static let descriptionMarginBottom = 10
    }
}
