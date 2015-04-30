//
//  ViewController.swift
//  NapDemo
//
//  Created by 郑行之 on 4/19/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import UIKit
import Nap
import Alamofire

class ViewController: UIViewController, AuthManagerDelegate {
  
  let options = [
    "baseURL"           : "https://api.twitter.com",
    "idKey"             : "user_id",
    "usernameKey"       : "screen_name",
    "signatureMethod"   : "HMAC-SHA1",
    "requestTokenPath"  : "oauth/request_token",
    "accessTokenPath"   : "oauth/access_token",
    "authorizePath"     : "oauth/authorize",
    "callbackURL"       : "https://example.com",
    "consumerKey"       : "***",
    "consumerSecret"    : "***"]

  
  var manager : OAuth1Manager?
  var account : OAuth1Account?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.manager = OAuth1Manager(options: self.options)
    self.manager?.authDelegate = self
    self.manager?.requestToken({
      (account, error) -> Void in
      if error != nil { println("Unable to get request token from Twitter") }
      else { self.manager?.authorize(loginController: LoginViewController()) }
    })
  }
  
  
  func didFinishAuthentication(manager: AuthManager, account: Account) {
    self.account = account as? OAuth1Account
    let request = self.manager?.request(.GET, "1.1/statuses/home_timeline.json", parameters: nil, encoding: ParameterEncoding.URL)
    request?.responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: {
      (request, response, result, error) -> Void in
      println(result)
    })
  }
  
  
  func didCancelAuthentication(manager: AuthManager) {
    println("Canceled")
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

