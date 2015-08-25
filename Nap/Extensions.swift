//
//  OAuth-String.swift
//  Nap
//
//  Created by 郑行之 on 4/19/15.
//  Copyright (c) 2015 Extremely Limited. All rights reserved.
//

import Foundation

extension String {
  
  func urlEncodedStringWithEncoding(encoding: NSStringEncoding) -> String {
    let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
    let charactersToLeaveUnescaped = "[]." as CFStringRef
    let raw: NSString = self
    let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, raw, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding))
    return result as String
  }
  
  
  func parametersFromQueryString() -> [String: String] {
    var parameters = [String: String]()
    let scanner = NSScanner(string: self)
    var key: NSString?
    var value: NSString?
    while !scanner.atEnd {
      key = nil
      scanner.scanUpToString("=", intoString: &key)
      scanner.scanString("=", intoString: nil)
      value = nil
      scanner.scanUpToString("&", intoString: &value)
      scanner.scanString("&", intoString: nil)
      if (key != nil && value != nil) { parameters.updateValue(value! as String, forKey: key! as String) }
    }
    return parameters
  }
}


extension Dictionary {
  
  func urlEncodedQueryStringWithEncoding(encoding: NSStringEncoding) -> String {
    var parts = [String]()
    for (key, value) in self {
      let keyString = "\(key)".urlEncodedStringWithEncoding(encoding)
      let valueString = "\(value)".urlEncodedStringWithEncoding(encoding)
      let query = "\(keyString)=\(valueString)" as String
      parts.append(query)
    }
    return parts.joinWithSeparator("&")
  }
}


extension NSMutableData {
  internal func appendBytes(arrayOfBytes: [UInt8]) {
    self.appendBytes(arrayOfBytes, length: arrayOfBytes.count)
  }
  
}


extension NSData {
  func bytes() -> [UInt8] {
    let count = self.length / sizeof(UInt8)
    var bytesArray = [UInt8](count: count, repeatedValue: 0)
    self.getBytes(&bytesArray, length:count * sizeof(UInt8))
    return bytesArray
  }
  
  class public func withBytes(bytes: [UInt8]) -> NSData {
    return NSData(bytes: bytes, length: bytes.count)
  }
}


func rotateLeft(v:UInt16, n:UInt16) -> UInt16 {
  return ((v << n) & 0xFFFF) | (v >> (16 - n))
}


func rotateLeft(v:UInt32, n:UInt32) -> UInt32 {
  return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}


func rotateLeft(x:UInt64, n:UInt64) -> UInt64 {
  return (x << n) | (x >> (64 - n))
}


func rotateRight(x:UInt16, n:UInt16) -> UInt16 {
  return (x >> n) | (x << (16 - n))
}


func rotateRight(x:UInt32, n:UInt32) -> UInt32 {
  return (x >> n) | (x << (32 - n))
}


func rotateRight(x:UInt64, n:UInt64) -> UInt64 {
  return ((x >> n) | (x << (64 - n)))
}


func reverseBytes(value: UInt32) -> UInt32 {
  let tmp1 = ((value & 0x000000FF) << 24) | ((value & 0x0000FF00) << 8)
  let tmp2 = ((value & 0x00FF0000) >> 8)  | ((value & 0xFF000000) >> 24)
  return tmp1 | tmp2
}


extension Int {
  
  public func bytes(totalBytes: Int = sizeof(Int)) -> [UInt8] {
    return arrayOfBytes(self, length: totalBytes)
  }
}


func arrayOfBytes<T>(value:T, length:Int? = nil) -> [UInt8] {
  
  let totalBytes = length ?? (sizeofValue(value) * 8)
  let valuePointer = UnsafeMutablePointer<T>.alloc(1)
  valuePointer.memory = value
  
  let bytesPointer = UnsafeMutablePointer<UInt8>(valuePointer)
  var bytes = [UInt8](count: totalBytes, repeatedValue: 0)
  for j in 0..<min(sizeof(T),totalBytes) {
    bytes[totalBytes - 1 - j] = (bytesPointer + j).memory
  }
  
  valuePointer.destroy()
  valuePointer.dealloc(1)
  
  return bytes
}



