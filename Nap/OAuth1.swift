//
//  OAuth1Manager.swift
//  Nap
//
//  Created by 郑行之 on 3/28/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Foundation
import Alamofire
import Security

#if os(iOS)
  import UIKit
#else
  import AppKit
#endif


public class OAuth1Manager : AuthManager {
  
  let consumerKey         : String!
  let consumerSecret      : String!
  let requestTokenPath    : String!
  let authorizeTokenPath  : String!
  let accessTokenPath     : String!
  
  let callbackURL         : NSURL?
  let scope               : String?
  let realm               : String?
  let signatureMethod     : String?
  let safariLogin         : Bool = false
  
  
  lazy var OAuthParameters : [String: AnyObject] = {
    var parameters = [String: AnyObject]()
    parameters["oauth_version"]          = "1.0"
    parameters["oauth_consumer_key"]     = self.consumerKey;
    parameters["oauth_timestamp"]        = "\(floor(NSDate().timeIntervalSince1970))"
    parameters["oauth_signature_method"] = "HMAC-SHA1";
    var uuid = CFUUIDGetUUIDBytes(CFUUIDCreate(kCFAllocatorDefault))
    let data = NSData(bytes: &uuid, length: sizeofValue(uuid))
    let nonce = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    parameters["oauth_nonce"] = nonce
    
    return parameters
  }()
  
  
  public override init?(options: [String : String]) {
    self.consumerKey = options["consumerKey"]
    self.consumerSecret = options["consumerSecret"]
    self.requestTokenPath = options["requestTokenPath"]
    self.authorizeTokenPath = options["authorizeTokenPath"]
    self.accessTokenPath = options["accessTokenPath"]
    var callbackURL : NSURL?
    if let url = options["callbackURL"] { callbackURL = NSURL(string: url) }
    self.callbackURL = callbackURL
    self.scope = options["scope"]
    self.realm = options["realm"]
    self.signatureMethod = options["signatureMethod"]
    super.init(options: options)
    if self.consumerKey == nil { return nil }
  }

  
  public required init(configuration: NSURLSessionConfiguration?) {
    fatalError("init(configuration:) has not been implemented")
  }
  
  
  public override func login(completionHandler: ((account: Account?, error: NSError?) -> Void)) {
    self.requestToken { (account, error) -> Void in
      if error != nil { completionHandler(account: nil,error: error) }
      else if account != nil {
        self.authorize(account!, completionHandler: { (account, error) -> Void in
          if error != nil { completionHandler(account: nil, error: error) }
          else if account != nil {
            self.accessToken(account!, completionHandler: { (account, error) -> Void in
              if error != nil { completionHandler(account: nil, error: error) }
              else if account != nil { completionHandler(account: account!, error: error) }
            })
          }
        })
      }
    }
  }
  
  
  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: ParameterEncoding) -> Request {
    
    func OAuth1Signature() -> String {
      return ""
    }
    
    
    func authorizationHeader() -> String {
      var authorizationParameters = self.OAuthParameters
      if let params = parameters {
        for (key,value) in params {
          if key.hasPrefix("oauth_") { authorizationParameters[key] = value }
        }
      }
      authorizationParameters["oauth_signature"] = OAuth1Signature()
      return ""
    }
    
    
    var mutableParameters = [String: AnyObject]()
    if let params = parameters {
      mutableParameters = params
      for (key,value) in params {
        if key.hasPrefix("oauth_") { mutableParameters.removeValueForKey("key") }
      }
    }
    
    var request = super.request(method, URLString, parameters: parameters)
    var mutableRequest = request.request as! NSMutableURLRequest
    mutableRequest.setValue(authorizationHeader(), forHTTPHeaderField: "Authorization")
    mutableRequest.HTTPShouldHandleCookies = false
    return request
  }
}


extension OAuth1Manager {
  
  public func requestToken(completionHandler: ((account: Account?, error: NSError?) -> Void)) {
    var parameters = [String:AnyObject]()
    parameters["oauth_callback"] = self.callbackURL
    parameters["scope"] = self.scope
    
    var error : NSError?
    let request = self.request(.GET, self.requestTokenPath, parameters: parameters, encoding: ParameterEncoding.URL)
    request.response { (request, response, object, error) -> Void in
      if error != nil { completionHandler(account: nil, error: error) }
      else {
        let account = OAuth1Account(manager: self)
//        account.requestToken = OAuth1Token(key: <#String#>, secret: <#String#>, verifier: nil)
        completionHandler(account: account, error: nil)
      }
    }
  }
  
  
  public func authorize(account: Account, completionHandler:((account: Account?, error: NSError?)  -> Void)) {
    let url = NSURL(string: self.authorizeTokenPath, relativeToURL: self.baseURL)
    if self.safariLogin == true {  }
    else {
      #if os(iOS)
        let loginViewController = LoginViewController()
        
        #else
        
      #endif
      
    }
  }
  
  
  public func accessToken(account: Account, completionHandler:((account: Account?, error: NSError?)  -> Void)) {
    if let oauth1Account = account as? OAuth1Account, requestToken = oauth1Account.requestToken {
      var parameters = [String: AnyObject]()
      parameters["oauth_token"]    = requestToken.key
      parameters["oauth_verifier"] = requestToken.verifier
      
      let request = self.request(.GET, self.accessTokenPath, parameters: parameters, encoding: ParameterEncoding.URL)
      request.response { (request, response, object, error) -> Void in
        
      }
    } else {
      var error : NSError?
      completionHandler(account: nil, error: error)
    }
  }
}


struct OAuth1Token {
  let key       : String
  let secret    : String
  let verifier  : String?
}


public class OAuth1Account: Account {
  var requestToken : OAuth1Token?
  var accessToken  : OAuth1Token?
}