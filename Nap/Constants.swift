//
//  Constants.swift
//  Nap
//
//  Created by 郑行之 on 4/22/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Foundation

public let NapErrorDomain = "nap.error"


public enum NapError : Int {
  case CannotReadOAuth1DataFromQueryString  = 1001
}


public protocol LoginViewControllerProtocol {
  func setManager(manager:AuthManager)
}