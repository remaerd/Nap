//
//  NapDemoTests.swift
//  NapDemoTests
//
//  Created by 郑行之 on 4/19/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import UIKit
import XCTest
import Nap
import Alamofire

class NapDemoTests: XCTestCase {
  
  let options = [
    "baseURL":"https://api.twitter.com",
    "idKey": "user_id",
    "usernameKey":"screen_name",
    "signatureMethod":"HMAC-SHA1",
    "requestTokenPath":"oauth/request_token",
    "accessTokenPath":"oauth/access_token",
    "authorizeTokenPath":"oauth/authorize",
    "callbackURL":"http://neue.io/callback",
    "consumerKey":"ET0UwdOuPYQGOl2pxjA41KWyp",
    "consumerSecret":"xFoalg85UCMSIL1AsjXldA6WZHtI9nAYAlRZYJPAe5F6FxtB3G"]
  
  
  var manager : OAuth1Manager?
  
  override func setUp() {
    super.setUp()
    self.manager = OAuth1Manager(options: self.options)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  
  func testCreateNewManager() {
    XCTAssertNotNil(self.manager, "Cannot create new OAuth1 Manager")
  }
  
  
  func testOAuth1Login() {
    let successExpectation = expectationWithDescription("Successful login")
    var failureExpectation = expectationWithDescription("Cannot login")
    
    self.waitForExpectationsWithTimeout(100, handler: { (error) -> Void in
      XCTAssertNil(error, "\(error)")
    })
  }
}
