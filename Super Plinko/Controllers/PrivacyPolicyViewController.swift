//
//  PrivacyPolicyViewController.swift
//  Super Plinko
//
//  Created by Artem Galiev on 20.09.2023.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    let clouseBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: PrivacyPolicyViewController.self, action: #selector(closeAction))
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let url = URL(string: "https://docs.google.com/document/d/1V5TrKmWAYIf-PUHaENdB4cecULDKh5w-1JDLqcuSDTU/edit?usp=sharing")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.rightBarButtonItem = clouseBarButtonItem
    }
    
    @objc func closeAction() {
        dismiss(animated: true)
    }
}

