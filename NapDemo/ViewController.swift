//
//  ViewController.swift
//  NapDemo
//
//  Created by 郑行之 on 4/19/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import UIKit
import Nap


class ViewController: UIViewController {
  
  let options = [
    "baseURL"           : "https://api.twitter.com",
    "idKey"             : "user_id",
    "usernameKey"       : "screen_name",
    "signatureMethod"   : "HMAC-SHA1",
    "requestTokenPath"  : "oauth/request_token",
    "accessTokenPath"   : "oauth/access_token",
    "authorizePath"     : "oauth/authorize",
    "callbackURL"       : "http://neue.io/callback",
    "consumerKey"       : "ET0UwdOuPYQGOl2pxjA41KWyp",
    "consumerSecret"    : "xFoalg85UCMSIL1AsjXldA6WZHtI9nAYAlRZYJPAe5F6FxtB3G"]

  
  var manager : OAuth1Manager?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.manager = OAuth1Manager(options: self.options)
    self.manager?.requestToken({ (account, error) -> Void in
      if error != nil { println("Unable to get request token from Twitter") }
      else { self.manager?.authorize(loginController: LoginViewController()) }
    })
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

