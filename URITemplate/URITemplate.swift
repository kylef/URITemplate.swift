//
//  URITemplate.swift
//  URITemplate
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation

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
    var expansion = template

    for (variable, value) in variables {
      let escapedValue = CFURLCreateStringByAddingPercentEscapes(nil, "\(value)", nil, ":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
      expansion = expansion.stringByReplacingOccurrencesOfString("{\(variable)}", withString: escapedValue, options: NSStringCompareOptions(0), range: nil)
    }

    return expansion
  }
}

public func ==(lhs:URITemplate, rhs:URITemplate) -> Bool {
  return lhs.template == rhs.template
}
