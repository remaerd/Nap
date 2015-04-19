//
//  AuthManager.swift
//  Nap
//
//  Created by 郑行之 on 3/28/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Alamofire

public class AuthManager : Manager {
  
  public let baseURL            : NSURL!
  public let keychainIdentifier : String!
  public let idKey              : String!
  public let usernameKey        : String?
  public lazy var accounts      = [Account]()
  
  
  public init?(options: [String:String]) {
    var url : NSURL?
    if options["baseURL"] != nil { url = NSURL(string: options["baseURL"]!) }
    self.baseURL = url
    self.keychainIdentifier = options["keychainIdentifier"]
    self.idKey = options["idKey"]
    self.usernameKey = options["usernameKey"]
    super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  }

  
  public required init(configuration: NSURLSessionConfiguration?) {
    fatalError("init(configuration:) has not been implemented")
  }
  
  
  public func login(completionHandler: ((account: Account?, error: NSError?) -> Void)) {
    
  }
  
  
  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: ParameterEncoding) -> Request {
    let url = self.baseURL.URLByAppendingPathComponent(URLString.URLString)
    return super.request(method, url.URLString, parameters: parameters, encoding: encoding)
  }
}