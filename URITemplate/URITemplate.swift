//
//  URITemplate.swift
//  URITemplate
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation

struct Expander {
  let prefix:String
  let joiner:String
  let handler:((String, String?) -> String)

  init(prefix:String, joiner:String, handler:((String, String?) -> String)) {
    self.prefix = prefix
    self.joiner = joiner
    self.handler = handler
  }
}

func handler(expansion:((variable:String, value:String) -> (String)))(variable:String, value:String?) -> String {
  if let value = value {
    return value
  }

  return ""
}

func expandPercentEscaped(variable:String, value:String?) -> String {
  if let value = value {
    return value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
  }

  return ""
}

func expandPercentEncoded(variable:String, value:String?) -> String {
  if let value = value {
    return value.percentEncoded()
  }

  return ""
}

func expandValue(variable:String, value:String?) -> String {
  if let value = value {
    return value
  }

  return ""
}

func expandKeyValue(variable:String, value:String?) -> String {
  if let value = value {
    return "\(variable)=\(value)"
  }

  return ""
}

// MARK: Extensions

extension NSRegularExpression {
  func substitute(string:String, block:((String) -> (String))) -> String {
    let oldString = string as NSString
    let range = NSRange(location: 0, length: oldString.length)
    var newString = string as NSString

    let matches = matchesInString(string, options: NSMatchingOptions(0), range: range)
    for match in matches.reverse() {
      let expression = oldString.substringWithRange(match.range)
      let replacement = block(expression)
      newString = newString.stringByReplacingCharactersInRange(match.range, withString: replacement)
    }

    return newString
  }
}

extension String {
  func percentEncoded() -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, self, nil, ":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
  }
}

// MARK: URITemplate

public struct URITemplate : Printable, Equatable, StringLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, UnicodeScalarLiteralConvertible {
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

  public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
  public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    template = value
  }

  public typealias UnicodeScalarLiteralType = StringLiteralType
  public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
    template = value
  }

  public init(stringLiteral value: StringLiteralType) {
    template = value
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
        if component.hasSuffix("*") {
          variables.append(component.substringToIndex(expression.endIndex.predecessor()))
        } else {
          variables.append(component)
        }
      }
    }

    return variables
  }

  // Expand template as a URI Template using the given variables
  public func expand(variables:[String:AnyObject]) -> String {
    let operatorHandlers:Dictionary<String, Expander> = [
      "+": Expander(prefix: "", joiner: ",", expandPercentEscaped),
      "#": Expander(prefix: "#", joiner: ",", expandPercentEscaped),
      ".": Expander(prefix: ".", joiner: ".", expandValue),
      ";": Expander(prefix: ";", joiner: ";", { (key, string) -> String in
        if let string = string {
          if countElements(string) > 0 {
            return "\(key)=\(string)"
          }
        }

        return "\(key)"
      }),
      "&": Expander(prefix: "&", joiner: "&", expandKeyValue),
      "?": Expander(prefix: "?", joiner: "&", expandKeyValue),
      "/": Expander(prefix: "/", joiner: "/", expandValue),
    ]

    return regex.substitute(template) { string in
      var expression = string.substringWithRange(string.startIndex.successor()..<string.endIndex.predecessor())

      let firstCharacter = expression.substringToIndex(expression.startIndex.successor())
      var expander:Expander! = operatorHandlers[firstCharacter]

      if let expander = expander {
        expression = expression.substringFromIndex(expression.startIndex.successor())
      } else {
        expander = Expander(prefix: "", joiner: ",", expandPercentEncoded)
      }

      return expander.prefix + expander.joiner.join(expression.componentsSeparatedByString(",").map { variable -> String in
        if let value: AnyObject = variables[variable] {
          return expander.handler(variable, "\(value)")
        }

        return expander.handler(variable, nil)
      })
    }
  }
}

public func ==(lhs:URITemplate, rhs:URITemplate) -> Bool {
  return lhs.template == rhs.template
}
