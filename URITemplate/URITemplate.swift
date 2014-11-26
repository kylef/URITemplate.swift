//
//  URITemplate.swift
//  URITemplate
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation

extension NSRegularExpression {
  func substitute(string:String, block:((String) -> (String))) -> String {
    let oldString = string as NSString
    let range = NSRange(location: 0, length: oldString.length)
    var newString = string as NSString

    enumerateMatchesInString(string, options: NSMatchingOptions(0), range: range) { (result, flags, bool) -> Void in
      let expression = oldString.substringWithRange(result.range)
      let replacement = block(expression)
      newString = newString.stringByReplacingCharactersInRange(result.range, withString: replacement)
    }

    return newString
  }
}

extension String {
  func percentEncoded() -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, self, nil, ":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
  }
}

public struct URITemplate : Printable, Equatable {
  let template:String

  var regex:NSRegularExpression {
    var error:NSError?
    let expression = NSRegularExpression(pattern: "\\{([^\\}]+)\\}", options: NSRegularExpressionOptions(0), error: &error)
    assert(error == nil)
    return expression!
  }

  var operators:[String] {
    return ["+", "#", ".", "/", ";", "?", "&", "|", "!", "@"]
  }

  public init(template:String) {
    self.template = template
  }

  public var description:String {
    return template
  }

  // Returns the set of keywords in the URI Template
  public func variables() -> [String] {
    let templateString = template as NSString
    let results = regex.matchesInString(templateString, options: NSMatchingOptions(0), range: NSRange(location: 0, length: templateString.length))
    let expressions = results.map { result -> String in
      let checkingResult = result as NSTextCheckingResult
      var range = checkingResult.range
      range.location += 1
      range.length -= 2
      return templateString.substringWithRange(range)
    }

    var variables = [String]()
    for expression in expressions {
      var expression = expression

      for op in operators {
        if expression.hasPrefix(op) {
          expression = expression.substringFromIndex(expression.startIndex.successor())
          break
        }
      }

      for component in expression.componentsSeparatedByString(",") {
        variables.append(component)
      }
    }

    return variables
  }

  // Expand template as a URI Template using the given variables
  public func expand(variables:[String:AnyObject]) -> String {
    return regex.substitute(template) { string in
      let expression = string.substringWithRange(string.startIndex.successor()..<string.endIndex.predecessor())

      if let value: AnyObject = variables[expression] {
        return "\(value)".percentEncoded()
      }

      return ""
    }
  }
}

public func ==(lhs:URITemplate, rhs:URITemplate) -> Bool {
  return lhs.template == rhs.template
}
