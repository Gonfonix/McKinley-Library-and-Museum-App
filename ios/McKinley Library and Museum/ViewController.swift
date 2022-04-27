//  ViewController.swift
//  McKinley Library and Museum was created by The Cabinet – Copyright © 2022

import UIKit
import WebKit

class ViewController: UIViewController, UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // User Account Credentials
    var email: String!
    var password: String!
    var firstName: String!
    var lastName: String!
    var birthday: String! // Birthday stored as String format
    
    // Intercept JavaScript code from the web app
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setNewBackgroundColor", let messageBody = message.body as? Int {
            print("New Background Color (Index): \(messageBody)") // DEBUG: Print out the index of the current background color
            UserDefaults.standard.set(messageBody, forKey: "previousBackgroundColor") // Store the latest background color index in UserDefaults
        } else if message.name == "enableDataCollection", let messageBody = message.body as? Bool {
            UserDefaults.standard.set(messageBody, forKey: "dataCollectionEnabled")
        } else if message.name == "collectData", let messageBody = message.body as? String {
            /*
             * Normally, here we would send the data we've collected somewhere. However, for now, we will just print the data out to the console...
             */
            print(messageBody)
        } else if message.name == "print", let messageBody = message.body as? String {
            print(messageBody)
        } else if message.name == "signupLoginEmail", let messageBody = message.body as? String {
            email = messageBody // Store the user's email address
        } else if message.name == "signupLoginPassword", let messageBody = message.body as? String {
            password = messageBody // Store the user's password
        } else if message.name == "signupFirstName", let messageBody = message.body as? String {
            firstName = messageBody // Store the user's first name
        } else if message.name == "signupLastName", let messageBody = message.body as? String {
            lastName = messageBody // Store the user's last name
        } else if message.name == "signupBirthday", let messageBody = message.body as? String {
            birthday = messageBody // Store the user's birthday
        } else if message.name == "processSignup" {
            /// Process Signup for Account Based on Variables Initialized
        } else if message.name == "processLogin" {
            /// Process Login for Account Based on Variables Initialized
        }
    }
    
    //var wv: WKWebView!
    var webView = WKWebView()
    
    // Log the User In
    // Proof of Concept!
    func logUserIntoAccount(_ userContentController: WKUserContentController) {
        // Verify Login Credentials...
        
        // Once verified, pass necessary information back to the app...
        let javaScript = ";" // ---> The Information to pass we ran as a JS Script
        
        let processLogin = WKUserScript(source: javaScript,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        userContentController.addUserScript(processLogin)
    }
    
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
        
        let javaScript2 = "optInDataCollection = \(UserDefaults.standard.bool(forKey: "dataCollectionEnabled"));"
        
        let setDataCollectionEnabled = WKUserScript(source: javaScript2,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        userContentController.addUserScript(setDataCollectionEnabled)
        
        // Log the User in
        logUserIntoAccount(userContentController)
        
        // Setup the processes for intercepting JavaScript code from the web app
        userContentController.add(self, name: "setNewBackgroundColor")
        userContentController.add(self, name: "enableDataCollection")
        userContentController.add(self, name: "collectData")
        
        userContentController.add(self, name: "signupLoginEmail")
        userContentController.add(self, name: "signupLoginPassword")
        userContentController.add(self, name: "signupFirstName")
        userContentController.add(self, name: "signupLastName")
        userContentController.add(self, name: "signupBirthday")
        userContentController.add(self, name: "processSignup")
        userContentController.add(self, name: "processLogin")
        
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
