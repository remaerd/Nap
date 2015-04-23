//
//  Account.swift
//  Nap
//
//  Created by 郑行之 on 3/28/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Foundation

public class Account : NSObject {
  
  public unowned let manager  : AuthManager
  public var userID           : String?
  public var username         : String?
  public var userInfo         : [String: AnyObject]?
  
  
  public init(manager: AuthManager) {
    self.manager = manager
  }
}