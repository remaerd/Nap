//
//  LoginViewController.swift
//  Nap
//
//  Created by 郑行之 on 4/22/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

// Note:
// Due to a bug cause by XCode or Swift. I cannot use the #if to define envoirment and write related code into the same file.
// So I have to write seperate file on different target to achieve a valid behavior

import UIKit

public typealias ViewController = UIViewController


public extension OAuth1Manager {
  
  public func authorize(loginController: ViewController? = nil) {
    if let key = (self.account as? OAuth1Account)?.requestToken?.key {
      let url = NSURL(string: "\(self.baseURL.URLString)/\(self.authorizePath)?oauth_token=\(key)")!
      if let viewController = loginController as? LoginViewControllerProtocol {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(loginController!, animated: true, completion: nil)
        viewController.setManager(self)
      } else { UIApplication.sharedApplication().openURL(url) }
    }
  }
}


public class LoginViewController : UIViewController, LoginViewControllerProtocol, UIWebViewDelegate {
  
  var webView   : UIWebView!
  var manager   : OAuth1Manager?
  
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  
  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  public func setManager(manager: AuthManager) {
    self.manager = manager as? OAuth1Manager
    if let authorizeURL = self.manager!.authorizeURL {
      let request = NSURLRequest(URL: authorizeURL)
      self.webView.loadRequest(request)
      self.webView.delegate = self
    }
  }
  
  
  public override func loadView() {
    super.loadView()
    self.view.backgroundColor = UIColor.whiteColor()
    let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
    self.webView = UIWebView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: UIScreen.mainScreen().bounds.height - 64))
    let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
    let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didTappedCancel")
    let navigationItem = UINavigationItem(title: self.manager!.serviceName)
    navigationItem.setLeftBarButtonItem(barButton, animated: false)
    navigationBar.pushNavigationItem(navigationItem, animated: false)
    self.view.addSubview(self.webView)
    self.view.addSubview(navigationBar)
  }
  
  
  func didTappedCancel() {
    self.manager?.authDelegate?.didCancelAuthentication(self.manager!)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if let verifier = self.manager!.verifierWithURLRequest(request) {
      self.manager?.accessToken(verifier, completionHandler: { (account, error) -> Void in
        if error != nil { print("Cannot return Access token") }
        else { self.manager?.authDelegate?.didFinishAuthentication(self.manager!,account:account!) }
      })
      self.dismissViewControllerAnimated(true, completion: nil)
      return false
    } else { return true }
  }
}