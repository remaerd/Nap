//
//  AuthManager.swift
//  Nap
//
//  Created by 郑行之 on 3/28/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Alamofire

public protocol AuthManagerDelegate {
  
  func didCancelAuthentication(manager:AuthManager)
  func didFinishAuthentication(manager:AuthManager, account:Account)
}


public class AuthManager : Manager {
  
  public let baseURL            : NSURL!
  public var keychainIdentifier : String?
  public var idKey              : String?
  public var usernameKey        : String?
  public var authDelegate       : AuthManagerDelegate?
  
  
  public init(baseURL:NSURL) {
    self.baseURL = baseURL
    super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  }
  
  
  public init?(options: [String:String]) {
    var url : NSURL?
    if options["baseURL"] != nil { url = NSURL(string: options["baseURL"]!) }
    self.baseURL = url
    self.keychainIdentifier = options["keychainIdentifier"]
    self.idKey = options["idKey"]
    self.usernameKey = options["usernameKey"]
    super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    if self.baseURL == nil {
      println("Base URL is missing")
      return nil
    }
  }

  
  public required init(configuration: NSURLSessionConfiguration?) {
    fatalError("init(configuration:) has not been implemented")
  }
  
  
  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: ParameterEncoding) -> Request {
    let url = self.baseURL.URLByAppendingPathComponent(URLString.URLString)
    return super.request(method, url.URLString, parameters: parameters, encoding: encoding)
  }
}