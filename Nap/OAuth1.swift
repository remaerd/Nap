//
//  OAuth1Manager.swift
//  Nap
//
//  Created by 郑行之 on 3/28/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Foundation
import Alamofire


#if os(iOS)
  import UIKit
#else
  import AppKit
#endif


public class OAuth1Manager : AuthManager {
  
  public enum Error : ErrorType {
    case InvalidProperties
  }
  
  
  let consumerKey             : String!
  let consumerSecret          : String!
  let requestTokenPath        : String!
  let authorizePath           : String!
  let accessTokenPath         : String!
  let callbackURL             : NSURL!
  
  let scope                   : String?
  let realm                   : String?
  let signatureMethod         : String?

  
  public var authorizeURL : NSURL? {
    if let key = (self.account as? OAuth1Account)?.requestToken?.key { return NSURL(string: "\(self.baseURL.URLString)/\(self.authorizePath)?oauth_token=\(key)")! }
    return nil
  }
  
  
  lazy var OAuthParameters : [String: AnyObject] = {
    var parameters = [String: AnyObject]()
    parameters["oauth_version"]           = "1.0"
    parameters["oauth_consumer_key"]      = self.consumerKey;
    parameters["oauth_timestamp"]         = String(Int64(NSDate().timeIntervalSince1970))
    parameters["oauth_signature_method"]  = "HMAC-SHA1";
    parameters["oauth_nonce"]             = (NSUUID().UUIDString as NSString).substringToIndex(8)
    return parameters
  }()
  
  
//  public init(baseURL: NSURL, consumerKey: String, consumerSecret:String, requestTokenPath:String, authorizeTokenPath:String, accessTokenPath:String, callbackURL: NSURL) {
//    super.init(baseURL: baseURL)
//    self.consumerKey = consumerKey
//    self.consumerSecret = consumerSecret
//    self.authorizeTokenPath = authorizeTokenPath
//    self.accessTokenPath = accessTokenPath
//    self.callbackURL = callbackURL
//  }
  
  
  public override init(options: [String : String]) throws {
    self.consumerKey = options["consumerKey"]
    self.consumerSecret = options["consumerSecret"]
    self.requestTokenPath = options["requestTokenPath"]
    self.authorizePath = options["authorizePath"]
    self.accessTokenPath = options["accessTokenPath"]
    var callbackURL : NSURL?
    if let url = options["callbackURL"] { callbackURL = NSURL(string: url) }
    self.callbackURL = callbackURL
    self.scope = options["scope"]
    self.realm = options["realm"]
    self.signatureMethod = options["signatureMethod"]
    do {
      try super.init(options: options)
    } catch {
      throw Error.InvalidBaseURL
    }
    if self.consumerKey == nil { print("consumerKey is missing") }
    if self.consumerSecret == nil { print("consumerSecret is missing") }
    if self.requestTokenPath == nil { print("requestTokenPath is missing") }
    if self.authorizePath == nil { print("authorizePath is missing") }
    if self.accessTokenPath == nil { print("accessTokenPath is missing") }
    if (self.consumerKey == nil || self.consumerSecret == nil || self.requestTokenPath == nil || self.authorizePath == nil || self.accessTokenPath == nil) {
      throw Error.InvalidProperties
    }
  }

  
  public required init(configuration: NSURLSessionConfiguration, serverTrustPolicyManager: ServerTrustPolicyManager?) {
      fatalError("init(configuration:serverTrustPolicyManager:) has not been implemented")
  }
  
  
  private func OAuth1Signature(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]) -> String? {
    var tokenSecret = "\(self.consumerSecret.urlEncodedStringWithEncoding(NSUTF8StringEncoding))&"
    if let accessToken = (self.account as? OAuth1Account)?.accessToken { tokenSecret +=  accessToken.secret.urlEncodedStringWithEncoding(NSUTF8StringEncoding) }
    else if let requestToken = (self.account as? OAuth1Account)?.requestToken { tokenSecret += requestToken.secret.urlEncodedStringWithEncoding(NSUTF8StringEncoding) }
    guard let key = tokenSecret.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
    
    var queryString = ""
    var queryStrings = parameters.urlEncodedQueryStringWithEncoding(NSUTF8StringEncoding).componentsSeparatedByString("&") as [String]
    queryStrings.sortInPlace { $0 < $1 }
    queryString = "&".join(queryStrings).urlEncodedStringWithEncoding(NSUTF8StringEncoding)
    
    let encodedURL = self.baseURL.URLByAppendingPathComponent(URLString.URLString).absoluteString.urlEncodedStringWithEncoding(NSUTF8StringEncoding)
    guard let message = "\(method.rawValue)&\(encodedURL)&\(queryString)".dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
    
    let sha1 = HMAC.sha1(key: key, message: message)
    
    let options : NSDataBase64EncodingOptions = [.Encoding64CharacterLineLength]
    return sha1?.base64EncodedStringWithOptions(options)
  }
  
  
  private func OAuth1AuthorizationHeader(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?) -> String {
    var authorizationParameters = self.OAuthParameters
    if let params = parameters {
      for (key,value) in params {
        if key.hasPrefix("oauth_") { authorizationParameters[key] = value }
      }
    }
    if let token = (self.account as? OAuth1Account)?.accessToken { authorizationParameters["oauth_token"] = token.key }
    authorizationParameters["oauth_signature"] = self.OAuth1Signature(method, URLString, parameters: authorizationParameters)
    var parameterComponents = authorizationParameters.urlEncodedQueryStringWithEncoding(NSUTF8StringEncoding).componentsSeparatedByString("&") as [String]
    parameterComponents.sortInPlace { $0 < $1 }
    var components = [String]()
    for component in parameterComponents {
      let subComponent = component.componentsSeparatedByString("=") as [String]
      if subComponent.count == 2 { components.append("\(subComponent[0])=\"\(subComponent[1])\"") }
    }
    return "OAuth " + ", ".join(components)
  }
  
  
  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: ParameterEncoding, headers: [String : String]?) -> Request {
    var mutableParameters = [String: AnyObject]()
    if let params = parameters {
      mutableParameters = params
      for (key,_) in params {
        if key.hasPrefix("oauth_") { mutableParameters.removeValueForKey(key) }
      }
    }
    
    let mutableRequest = NSMutableURLRequest(URL: self.baseURL.URLByAppendingPathComponent(URLString.URLString))
    mutableRequest.HTTPMethod = method.rawValue
    switch encoding {
    case .URL: Alamofire.ParameterEncoding.URL.encode(mutableRequest, parameters: parameters)
    case .JSON: Alamofire.ParameterEncoding.JSON.encode(mutableRequest, parameters: parameters)
    default: break
    }
    mutableRequest.setValue(self.OAuth1AuthorizationHeader(method, URLString, parameters: parameters), forHTTPHeaderField: "Authorization")
    return Alamofire.request(mutableRequest)
  }
}


extension OAuth1Manager {
  
  public func requestToken(completionHandler: ((account: Account?, error: NSError?) -> Void)) {
    var parameters = [String:AnyObject]()
    parameters["oauth_callback"] = self.callbackURL
    parameters["scope"] = self.scope
    
    let request = self.request(.POST, self.requestTokenPath, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil)
    request.response { (request, response, result, error) -> Void in
      if error != nil { completionHandler(account: nil, error: error) }
      else if let data = result, queryString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
        let parameters = queryString.parametersFromQueryString()
        if let key = parameters["oauth_token"], secret = parameters["oauth_token_secret"] {
          let account = OAuth1Account(manager: self)
          account.requestToken = OAuth1Token(key: key, secret: secret)
          self.account = account
          completionHandler(account: self.account!, error: nil)
        } else {
          let error = NSError(domain: NapErrorDomain, code: NapError.CannotReadOAuth1DataFromQueryString.rawValue, userInfo: nil)
          completionHandler(account: nil, error: error)
        }
      }
    }
  }
  
  
  public func verifierWithURLRequest(request:NSURLRequest) -> String? {
    let urlString = "\(request.URL!.scheme)://\(request.URL!.host!)\(request.URL!.path!)"
    if let parameters = request.URL?.query?.parametersFromQueryString() where urlString == self.callbackURL.URLString {
      if let verifier = parameters["oauth_verifier"] { return verifier }
    }
    return nil
  }

  
  public func accessToken(verifier: String, completionHandler: ((account: Account?, error: NSError?) -> Void)) {
    
    if let oauth1Account = self.account as? OAuth1Account, requestToken = oauth1Account.requestToken {
      var parameters = [String: AnyObject]()
      parameters["oauth_token"]    = requestToken.key
      parameters["oauth_verifier"] = verifier
      let request = self.request(.GET, self.accessTokenPath, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil)
      
      request.response {
        (request, response, object, error) -> Void in
        if error != nil { completionHandler(account: nil, error: error) }
        else if let data = object, parameterString = NSString(data: data, encoding: NSUTF8StringEncoding) {
          let parameters = (parameterString as String).parametersFromQueryString()
          if let token = parameters["oauth_token"], secret = parameters["oauth_token_secret"] {
            let accessToken = OAuth1Token(key: token, secret: secret)
            (self.account as? OAuth1Account)?.accessToken = accessToken
            if let key = self.idKey, id = parameters[key] { self.account?.userID = id }
            if let key = self.usernameKey, username = parameters[key] { self.account?.username = username }
            completionHandler(account: self.account, error: nil)
          }
        } else {
          let error = NSError(domain: NapErrorDomain, code: NapError.CannotReadOAuth1DataFromQueryString.rawValue, userInfo: nil)
          completionHandler(account: nil, error: error)
        }
      }
    } else {
      let error = NSError(domain: NapErrorDomain, code: NapError.OAuth1AccountNotFound.rawValue, userInfo: nil)
      completionHandler(account: nil, error: error)
    }
  }
}


public struct OAuth1Token {
  
  public let key    : String
  public let secret : String
  
  public init(key:String, secret:String) {
    self.key = key
    self.secret = secret
  }
}


public class OAuth1Account: Account {
  public var requestToken : OAuth1Token?
  public var accessToken  : OAuth1Token?
}