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
  
  public enum Error : ErrorType {
    case InvalidBaseURL
  }
  
  
  public let serviceName        : String
  public let baseURL            : NSURL!
  public var keychainIdentifier : String?
  public var idKey              : String?
  public var usernameKey        : String?
  public var authDelegate       : AuthManagerDelegate?
  public var account            : Account?
  
  
  public init(serviceName: String, baseURL:NSURL) {
    self.baseURL = baseURL
    self.serviceName = serviceName
    super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  }
  
  
  public init(options: [String:String]) throws {
    var url : NSURL?
    if options["baseURL"] != nil { url = NSURL(string: options["baseURL"]!) }
    self.baseURL = url
    if let serviceName = options["serviceName"] { self.serviceName = serviceName }
    else { self.serviceName = "" }
    self.keychainIdentifier = options["keychainIdentifier"]
    self.idKey = options["idKey"]
    self.usernameKey = options["usernameKey"]
    super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    if self.baseURL == nil { throw Error.InvalidBaseURL }
  }
  
  
  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: ParameterEncoding, headers: [String : String]?) -> Request {
    let url = self.baseURL.URLByAppendingPathComponent(URLString.URLString)
    return super.request(method, url.URLString, parameters: parameters, encoding: encoding)
  }
}