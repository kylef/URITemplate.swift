//
//  URITemplate.swift
//  URITemplate
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation

// MARK: URITemplate

/// A data structure to represent an RFC6570 URI template.
public struct URITemplate : Printable, Equatable, Hashable, StringLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, UnicodeScalarLiteralConvertible {
  let template:String

  var regex:NSRegularExpression {
    var error:NSError?
    let expression = NSRegularExpression(pattern: "\\{([^\\}]+)\\}", options: NSRegularExpressionOptions(0), error: &error)
    assert(error == nil)
    return expression!
  }

  var operators:[Operator] {
    return [
      StringExpansion(),
      ReservedExpansion(),
      FragmentExpansion(),
      LabelExpansion(),
      PathSegmentExpansion(),
      PathStyleParameterExpansion(),
      FormStyleQueryExpansion(),
      FormStyleQueryContinuation(),
    ]
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

  public var hashValue:Int {
    return template.hashValue
  }

  /// Returns the set of keywords in the URI Template
  public var variables:[String] {
    let expressions = regex.matches(template).map { expression in
      // Removes the { and } from the expression
      expression.substringWithRange(expression.startIndex.successor()..<expression.endIndex.predecessor())
    }

    return expressions.map { expression -> [String] in
      var expression = expression

      for op in self.operators {
        if let op = op.op {
          if expression.hasPrefix(op) {
            expression = expression.substringFromIndex(expression.startIndex.successor())
            break
          }
        }
      }

      return expression.componentsSeparatedByString(",").map { component in
        if component.hasSuffix("*") {
          return component.substringToIndex(expression.endIndex.predecessor())
        } else {
          return component
        }
      }
    }.reduce([], +)
  }

  /// Expand template as a URI Template using the given variables
  public func expand(variables:[String:AnyObject]) -> String {
    return regex.substitute(template) { string in
      var expression = string.substringWithRange(string.startIndex.successor()..<string.endIndex.predecessor())
      let firstCharacter = expression.substringToIndex(expression.startIndex.successor())

      var op = self.operators.filter {
        if let op = $0.op {
          return op == firstCharacter
        }

        return false
      }.first

      if (op != nil) {
        expression = expression.substringFromIndex(expression.startIndex.successor())
      } else {
        op = self.operators.first
      }

      return op!.prefix + op!.joiner.join(expression.componentsSeparatedByString(",").map { vari -> String in
        var variable = vari
        var prefix:Int?

        if let range = variable.rangeOfString(":") {
          prefix = variable.substringFromIndex(range.endIndex).toInt()
          variable = variable.substringToIndex(range.startIndex)
        }

        let explode = variable.hasSuffix("*")

        if explode {
          variable = variable.substringToIndex(variable.endIndex.predecessor())
        }

        if let value:AnyObject = variables[variable] {
          return op!.expand(variable, value: value, explode: explode, prefix:prefix)
        }

        return op!.expand(variable, value:nil, explode:false, prefix:prefix)
      })
    }
  }

  /// Extract the variables used in a given URL
  public func extract(url:String) -> Dictionary<String, String> {
    let regex = NSRegularExpression(pattern: "(\\{([^\\}]+)\\})|[^(.*)]", options: NSRegularExpressionOptions(0), error: nil)!
    let pattern = regex.substitute(self.template) { expression in
      if expression.hasPrefix("{") && expression.hasSuffix("}") {
        return "(.*)"
      } else {
        return NSRegularExpression.escapedPatternForString(expression)
      }
    }

    let expression = NSRegularExpression(pattern: "^\(pattern)$", options: NSRegularExpressionOptions(0), error: nil)
    if let expression = expression {
      let matches = expression.matches(url)

      var extractedVariables = Dictionary<String, String>()

      if matches.count == variables.count {
        for index in 0..<matches.count {
          extractedVariables[variables[index]] = matches[index].stringByRemovingPercentEncoding
        }
      }

      return extractedVariables
    }

    return [:]
  }
}

public func ==(lhs:URITemplate, rhs:URITemplate) -> Bool {
  return lhs.template == rhs.template
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

  func matches(string:String) -> [String] {
    let input = string as NSString
    let range = NSRange(location: 0, length: input.length)
    let results = matchesInString(input, options: NSMatchingOptions(0), range: range)

    return results.map { result -> String in
      let checkingResult = result as NSTextCheckingResult
      var range = checkingResult.range
      return input.substringWithRange(range)
    }
  }
}

extension String {
  func percentEncoded() -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, self, nil, ":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
  }
}

// MARK: Operators

protocol Operator {
  /// Operator
  var op:String? { get }

  /// Prefix for the expanded string
  var prefix:String { get }

  /// Character to use to join expanded components
  var joiner:String { get }

  func expand(variable:String, value:AnyObject?, explode:Bool, prefix:Int?) -> String
}

class BaseOperator {
  var joiner:String { return "," }

  func expand(variable:String, value:AnyObject?, explode:Bool, prefix:Int?) -> String {
    if var value:AnyObject = value {
      var expandedValue:String!
      if let values = value as? [String:AnyObject] {
        let joiner = explode ? self.joiner : ","
        let keyValueJoiner = explode ? "=" : ","
        let elements = map(values, { (key, value) -> String in
          let expandValue = self.expand(value: "\(value)")
          return "\(key)\(keyValueJoiner)\(expandValue)"
        })
        expandedValue = join(joiner, elements)
      } else if let values = value as? [AnyObject] {
        let joiner = explode ? self.joiner : ","
        expandedValue = joiner.join(values.map { self.expand(value: "\($0)") })
      } else {
        expandedValue = expand(value:"\(value)", prefix:prefix)
      }

      return expandedValue
    }

    return ""
  }

  func expand(# value:String) -> String {
    return value
  }

  func expand(# value:String, prefix:Int?) -> String {
    if let prefix = prefix {
      if countElements(value) > prefix {
        let index = advance(value.startIndex, prefix)
        return expand(value: value.substringToIndex(index))
      }
    }

    return expand(value: value)
  }
}

/// RFC6570 (3.2.2) Simple String Expansion: {var}
class StringExpansion : BaseOperator, Operator {
  var op:String? { return nil }
  var prefix:String { return "" }
  override var joiner:String { return "," }

  override func expand(# value:String) -> String {
    return value.percentEncoded()
  }
}

/// RFC6570 (3.2.3) Reserved Expansion: {+var}
class ReservedExpansion : BaseOperator, Operator {
  var op:String? { return "+" }
  var prefix:String { return "" }
  override var joiner:String { return "," }

  override func expand(# value:String) -> String {
    return value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
  }
}

/// RFC6570 (3.2.4) Fragment Expansion {#var}
class FragmentExpansion : BaseOperator, Operator {
  var op:String? { return "#" }
  var prefix:String { return "#" }
  override var joiner:String { return "," }

  override func expand(# value:String) -> String {
    return value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
  }
}

/// RFC6570 (3.2.5) Label Expansion with Dot-Prefix: {.var}
class LabelExpansion : BaseOperator, Operator {
  var op:String? { return "." }
  var prefix:String { return "." }
  override var joiner:String { return "." }

  override func expand(# value:String) -> String {
    return value.percentEncoded()
  }
}

/// RFC6570 (3.2.6) Path Segment Expansion: {/var}
class PathSegmentExpansion : BaseOperator, Operator {
  var op:String? { return "/" }
  var prefix:String { return "/" }
  override var joiner:String { return "/" }

  override func expand(# value:String) -> String {
    return value.percentEncoded()
  }
}

/// RFC6570 (3.2.7) Path-Style Parameter Expansion: {;var}
class PathStyleParameterExpansion : BaseOperator, Operator {
  var op:String? { return ";" }
  var prefix:String { return ";" }
  override var joiner:String { return ";" }

  override func expand(variable:String, value:AnyObject?, explode:Bool, prefix:Int?) -> String {
    if let value:AnyObject = value {
      let value = "\(value)"
      if countElements(value) > 0 {
        let expandedValue = expand(value:value, prefix:prefix)
        return "\(variable)=\(expandedValue)"
      }
    }

    return "\(variable)"
  }
}

/// RFC6570 (3.2.8) Form-Style Query Expansion: {?var}
class FormStyleQueryExpansion : BaseOperator, Operator {
  var op:String? { return "?" }
  var prefix:String { return "?" }
  override var joiner:String { return "&" }

  override func expand(variable:String, value:AnyObject?, explode:Bool, prefix:Int?) -> String {
    if let value:AnyObject = value {
      let expandedValue = expand(value:"\(value)", prefix:prefix)
      return "\(variable)=\(expandedValue)"
    }

    return ""
  }
}

/// RFC6570 (3.2.9) Form-Style Query Continuation: {&var}
class FormStyleQueryContinuation : BaseOperator, Operator {
  var op:String? { return "&" }
  var prefix:String { return "&" }
  override var joiner:String { return "&" }

  override func expand(variable:String, value:AnyObject?, explode:Bool, prefix:Int?) -> String {
    if let value:AnyObject = value {
      let expandedValue = expand(value:"\(value)", prefix:prefix)
      return "\(variable)=\(expandedValue)"
    }

    return ""
  }
}
