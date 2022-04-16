//  ViewController.swift
//  McKinley Library and Museum was created by The Cabinet – Copyright © 2022

import UIKit
import WebKit

class ViewController: UIViewController, UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler {
    // Intercept JavaScript code from the web app
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setNewBackgroundColor", let messageBody = message.body as? Int {
            print("New Background Color (Index): \(messageBody)") // DEBUG: Print out the index of the current background color
            UserDefaults.standard.set(messageBody, forKey: "previousBackgroundColor") // Store the latest background color index in UserDefaults
        } else if message.name == "print", let messageBody = message.body as? String {
            print(messageBody)
        }
    }
    
    //var wv: WKWebView!
    var webView = WKWebView()
    
    override func loadView() {
        let wc = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        wc.allowsInlineMediaPlayback = true
        wc.mediaTypesRequiringUserActionForPlayback = []

        // Send the previous background color index to the web app, so a unique background can be generated each time the app loads
        //let javaScript = "hypeDocument.setRandImageIndexOnLoad(\(UserDefaults.standard.integer(forKey: "previousBackgroundColor")));"
        print("Previous Background Color (Index): \(UserDefaults.standard.integer(forKey: "previousBackgroundColor"))")
        let javaScript = "randImageIndex = \(UserDefaults.standard.integer(forKey: "previousBackgroundColor"));"
        
        let setPreviousBackgroundColor = WKUserScript(source: javaScript,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        userContentController.addUserScript(setPreviousBackgroundColor)
        
        // Setup the processes for intercepting JavaScript code from the web app
        userContentController.add(self, name: "setNewBackgroundColor")
        userContentController.add(self, name: "print") // Will be used to print data out to the console
        wc.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: wc)
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.delegate = self
        webView.isOpaque = false
        webView.isHidden = false
        
        // Make view extend to notch and bottom of display
        webView.scrollView.contentInsetAdjustmentBehavior = .never;
        view = webView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "/html/index", withExtension: "html")
        let request = URLRequest(url: url!)
        
        webView.load(request)
        webView.translatesAutoresizingMaskIntoConstraints = false;
    }
}
