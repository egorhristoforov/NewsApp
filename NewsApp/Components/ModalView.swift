//
//  ModalView.swift
//  NewsApp
//
//  Created by Egor on 19.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit

class ModalView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    init(title: String, description: String, buttonText: String? = nil) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        descriptionLabel.text = description
        button.setTitle(buttonText, for: .normal)
        
        button.isHidden = buttonText == nil
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(button)
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
        }
        
        button.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(LayoutConstants.buttonMarginHorizontal)
            make.trailing.equalToSuperview().offset(-LayoutConstants.buttonMarginHorizontal)
            make.height.equalTo(LayoutConstants.buttonHeight)
            make.bottom.equalToSuperview().offset(-LayoutConstants.buttonMarginBottom)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(LayoutConstants.buttonMarginTop)
        }
    }
}

private extension ModalView {
    enum LayoutConstants {
        static let titleMarginHorizontal = 10
        static let titleMarginTop = 5
        
        static let descriptionMarginTop = 5
        static let descriptionMarginHorizontal = 10
        
        static let buttonMarginHorizontal = 30
        static let buttonHeight = 40
        static let buttonMarginTop = 15
        static let buttonMarginBottom = 5
    }
}
