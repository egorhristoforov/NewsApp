//
//  WebViewViewController.swift
//  NewsApp
//
//  Created by Egor on 14.09.2020.
//  Copyright © 2020 EgorHristoforov. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController, UINavigationControllerDelegate {
    
    private let viewModel: WebViewModel
    
    private let webView: WKWebView = {
        let view = WKWebView()
        
        return view
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = webView
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: viewModel.url))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.didClose.onNext(())
    }
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
    }
}
