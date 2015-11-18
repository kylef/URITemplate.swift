import Foundation

// MARK: URITemplate

/// A data structure to represent an RFC6570 URI template.
public struct URITemplate : CustomStringConvertible, Equatable, Hashable, StringLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, UnicodeScalarLiteralConvertible {
  /// The underlying URI template
  public let template: String

  var operators: [Operator] {
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

  /// Initialize a URITemplate with the given template
  public init(template: String) {
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

  /// Returns a description of the URITemplate
  public var description: String {
    return template
  }

  public var hashValue: Int {
    return template.hashValue
  }

  /// Returns the all of expressions in the URI Template
  var expressions: [String] {
    var expressions: [String] = []

    let scanner = Scanner(content: template)
    while !scanner.isEmpty {
      scanner.scan(until: "{")

      if !scanner.isEmpty {
        let expression = scanner.scan(until: "}")
        expressions.append(expression)
      }
    }

    return expressions
  }

  /// Constructs a string from the template by mapping the expressions
  func expressionSubstitute(closure: String -> String) -> String {
    var output = ""

    let scanner = Scanner(content: template)
    while !scanner.isEmpty {
      output.appendContentsOf(scanner.scan(until: "{"))

      if !scanner.isEmpty {
        let expression = scanner.scan(until: "}")
        output.appendContentsOf(closure(expression))
      }
    }

    return output
  }

  /// Returns all of keywords found in the URI Template
  public var variables: [String] {
    func trimOperator(expression: String) -> String {
      if let prefix = expression.characters.first {
        let isOperator = operators.flatMap { $0.op }.contains(prefix)
        if isOperator {
          return expression[expression.startIndex.successor()..<expression.endIndex]
        }
      }

      return expression
    }

    func stripExplode(expression: String) -> String {
      if expression.hasSuffix("*") {
        return expression[expression.startIndex..<expression.endIndex.predecessor()]
      }

      return expression
    }

    func splitExpression(expression: String) -> [String] {
      return expression.characters.split(",").map(String.init)
    }

    return expressions
      .map(trimOperator)
      .map(splitExpression)
      .reduce([], combine: +)
      .map(stripExplode)
  }

  /// Expand template as a URI Template using the given variables
  public func expand(variables: [String: AnyObject]) -> String {
    func findOperator(expression: String) -> (Operator, String) {
      let firstCharacter = expression.characters.first
      let ops = operators.filter { $0.op == firstCharacter }
      if let op = ops.first {
        return (op, expression[expression.startIndex.successor()..<expression.endIndex])
      }

      return (StringExpansion(), expression)
    }

    return expressionSubstitute { string in
      let (op, expression) = findOperator(string)
      return op.expand(expression: expression, variables: variables)
    }
  }

  func regexForVariable(variable: String, op: Operator?) -> String {
    if op != nil {
      return "(.*)"
    } else {
      return "([A-z0-9%_\\-]+)"
    }
  }

  func regexForExpression(expression: String) -> String {
    var expression = expression

    let op = operators.filter {
      $0.op != nil && expression.hasPrefix(String($0.op!))
    }.first

    if op != nil {
      expression = expression[expression.startIndex.successor()..<expression.endIndex]
    }

    let regexes = expression.componentsSeparatedByString(",").map {
      return self.regexForVariable($0, op: op)
    }

    return regexes.joinWithSeparator((op ?? StringExpansion()).joiner)
  }

  var extractionRegex: NSRegularExpression? {
    let regex = try! NSRegularExpression(pattern: "(\\{([^\\}]+)\\})|[^(.*)]", options: NSRegularExpressionOptions())

    let pattern = regex.substitute(self.template) { expression in
      if expression.hasPrefix("{") && expression.hasSuffix("}") {
        let startIndex = expression.startIndex.successor()
        let endIndex = expression.endIndex.predecessor()
        return self.regexForExpression(expression[startIndex..<endIndex])
      } else {
        return NSRegularExpression.escapedPatternForString(expression)
      }
    }

    return try? NSRegularExpression(pattern: "^\(pattern)$", options: NSRegularExpressionOptions())
  }

  /// Extract the variables used in a given URL
  public func extract(url: String) -> [String: String]? {
    if let expression = extractionRegex {
      let input = url as NSString
      let range = NSRange(location: 0, length: input.length)
      let results = expression.matchesInString(url, options: NSMatchingOptions(), range: range)

      if let result = results.first {
        var extractedVariables = [String: String]()

        for (index, variable) in variables.enumerate() {
          let range = result.rangeAtIndex(index + 1)
          let value = input.substringWithRange(range).stringByRemovingPercentEncoding
          extractedVariables[variable] = value
        }

        return extractedVariables
      }
    }

    return nil
  }
}

/// Determine if two URITemplate's are equivalent
public func == (lhs: URITemplate, rhs: URITemplate) -> Bool {
  return lhs.template == rhs.template
}

// MARK: Extensions

extension NSRegularExpression {
  func substitute(string: String, block: (String -> String)) -> String {
    let oldString = string as NSString
    let range = NSRange(location: 0, length: oldString.length)
    var newString = string as NSString

    let matches = matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: range)
    for match in Array(matches.reverse()) {
      let expression = oldString.substringWithRange(match.range)
      let replacement = block(expression)
      newString = newString.stringByReplacingCharactersInRange(match.range, withString: replacement)
    }

    return newString as String
  }
}

extension String {
  func percentEncoded() -> String {
    let allowedCharacters = NSCharacterSet(charactersInString: ":/?&=;+!@#$()',*").invertedSet
    return stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!
  }
}

// MARK: Operators

protocol Operator {
  /// Operator
  var op: Character? { get }

  /// Prefix for the expanded string
  var prefix:String { get }

  /// Character to use to join expanded components
  var joiner:String { get }

  func expand(variable: String, value: AnyObject?, explode: Bool, prefix: Int?) -> String?
}

extension Operator {
  func expand(expression expression: String, variables: [String: AnyObject]) -> String {
    let expansions = expression.characters.split(",").map(String.init)
      .flatMap { expand(variable: $0, variables: variables) }
      .reduce([]) { $0 + [$1] }

    if !expansions.isEmpty {
      return prefix + expansions.joinWithSeparator(joiner)
    }

    return ""
  }

  func expand(variable variable: String, variables: [String: AnyObject]) -> String? {
    var variable = variable
    var prefix: Int?

    if let range = variable.rangeOfString(":") {
      prefix = Int(variable.substringFromIndex(range.endIndex))
      variable = variable.substringToIndex(range.startIndex)
    }

    let explode = variable.hasSuffix("*")

    if explode {
      variable = variable.substringToIndex(variable.endIndex.predecessor())
    }

    if let value = variables[variable] {
      return expand(variable, value: value, explode: explode, prefix:prefix)
    }

    return expand(variable, value:nil, explode:false, prefix:prefix)
  }
}

class BaseOperator {
  var joiner:String { return "," }

  func expand(variable: String, value: AnyObject?, explode: Bool, prefix: Int?) -> String? {
    if let values = value as? [String:AnyObject] {
      return expand(variable:variable, value: values, explode: explode)
    } else if let values = value as? [AnyObject] {
      return expand(variable:variable, value: values, explode: explode)
    } else if let _ = value as? NSNull {
      return expand(variable:variable)
    } else if let value = value {
      return expand(variable:variable, value:"\(value)", prefix:prefix)
    }

    return expand(variable:variable)
  }

  // Point to overide to expand a value (i.e, perform encoding)
  func expand(value value: String) -> String {
    return value
  }

  // Point to overide to expanding a string
  func expand(variable variable: String, value: String, prefix: Int?) -> String {
    if let prefix = prefix {
      if value.characters.count > prefix {
        let index = value.startIndex.advancedBy(prefix, limit: value.endIndex)
        return expand(value: value.substringToIndex(index))
      }
    }

    return expand(value: value)
  }

  // Point to overide to expanding an array
  func expand(variable  variable: String, value: [AnyObject], explode: Bool) -> String? {
    let joiner = explode ? self.joiner : ","
    return value.map { self.expand(value: "\($0)") }.joinWithSeparator(joiner)
  }

  // Point to overide to expanding a dictionary
  func expand(variable variable: String, value: [String:AnyObject], explode: Bool) -> String? {
    let joiner = explode ? self.joiner : ","
    let keyValueJoiner = explode ? "=" : ","
    let elements = value.map { key, value -> String in
      let expandedKey = expand(value: key)
      let expandedValue = expand(value: "\(value)")
      return "\(expandedKey)\(keyValueJoiner)\(expandedValue)"
    }

    return elements.joinWithSeparator(joiner)
  }

  // Point to overide when value not found
  func expand(variable variable: String) -> String? {
    return nil
  }
}

/// RFC6570 (3.2.2) Simple String Expansion: {var}
class StringExpansion : BaseOperator, Operator {
  var op: Character? { return nil }
  var prefix: String { return "" }
  override var joiner: String { return "," }

  override func expand(value value: String) -> String {
    return value.percentEncoded()
  }
}

/// RFC6570 (3.2.3) Reserved Expansion: {+var}
class ReservedExpansion : BaseOperator, Operator {
  var op: Character? { return "+" }
  var prefix: String { return "" }
  override var joiner: String { return "," }

  override func expand(value value: String) -> String {
    return value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
  }
}

/// RFC6570 (3.2.4) Fragment Expansion {#var}
class FragmentExpansion : BaseOperator, Operator {
  var op: Character? { return "#" }
  var prefix: String { return "#" }
  override var joiner: String { return "," }

  override func expand(value value: String) -> String {
    return value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
  }
}

/// RFC6570 (3.2.5) Label Expansion with Dot-Prefix: {.var}
class LabelExpansion : BaseOperator, Operator {
  var op: Character? { return "." }
  var prefix: String { return "." }
  override var joiner: String { return "." }

  override func expand(value value: String) -> String {
    return value.percentEncoded()
  }

  override func expand(variable variable: String, value: [AnyObject], explode: Bool) -> String? {
    if !value.isEmpty {
      return super.expand(variable: variable, value: value, explode: explode)
    }

    return nil
  }
}

/// RFC6570 (3.2.6) Path Segment Expansion: {/var}
class PathSegmentExpansion : BaseOperator, Operator {
  var op: Character? { return "/" }
  var prefix: String { return "/" }
  override var joiner: String { return "/" }

  override func expand(value  value: String) -> String {
    return value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
  }

  override func expand(variable variable: String, value: [AnyObject], explode: Bool) -> String? {
    if !value.isEmpty {
      return super.expand(variable: variable, value: value, explode: explode)
    }

    return nil
  }
}

/// RFC6570 (3.2.7) Path-Style Parameter Expansion: {;var}
class PathStyleParameterExpansion : BaseOperator, Operator {
  var op: Character? { return ";" }
  var prefix: String { return ";" }
  override var joiner: String { return ";" }

  override func expand(value value: String) -> String {
    return value.percentEncoded()
  }

  override func expand(variable variable: String, value: String, prefix: Int?) -> String {
    if !value.isEmpty {
      let expandedValue = super.expand(variable: variable, value: value, prefix: prefix)
      return "\(variable)=\(expandedValue)"
    }

    return variable
  }

  override func expand(variable variable: String, value: [AnyObject], explode: Bool) -> String? {
    let joiner = explode ? self.joiner : ","
    let expandedValue = value.map {
      let expandedValue = self.expand(value: "\($0)")

      if explode {
        return "\(variable)=\(expandedValue)"
      }

      return expandedValue
    }.joinWithSeparator(joiner)

    if !explode {
      return "\(variable)=\(expandedValue)"
    }

    return expandedValue
  }

  override func expand(variable variable: String, value: [String:AnyObject], explode: Bool) -> String? {
    let expandedValue = super.expand(variable: variable, value: value, explode: explode)

    if let expandedValue = expandedValue {
      if (!explode) {
        return "\(variable)=\(expandedValue)"
      }
    }

    return expandedValue
  }
}

/// RFC6570 (3.2.8) Form-Style Query Expansion: {?var}
class FormStyleQueryExpansion : BaseOperator, Operator {
  var op: Character? { return "?" }
  var prefix: String { return "?" }
  override var joiner: String { return "&" }

  override func expand(value value: String) -> String {
    return value.percentEncoded()
  }

  override func expand(variable variable: String, value: String, prefix: Int?) -> String {
    let expandedValue = super.expand(variable: variable, value: value, prefix: prefix)
    return "\(variable)=\(expandedValue)"
  }

  override func expand(variable variable: String, value: [AnyObject], explode: Bool) -> String? {
    if !value.isEmpty {
      let joiner = explode ? self.joiner : ","
      let expandedValue = value.map {
        let expandedValue = self.expand(value: "\($0)")

        if explode {
          return "\(variable)=\(expandedValue)"
        }

        return expandedValue
      }.joinWithSeparator(joiner)

      if !explode {
        return "\(variable)=\(expandedValue)"
      }

      return expandedValue
    }

    return nil
  }

  override func expand(variable variable: String, value: [String:AnyObject], explode: Bool) -> String? {
    if !value.isEmpty {
      let expandedVariable = self.expand(value: variable)
      let expandedValue = super.expand(variable: variable, value: value, explode: explode)

      if let expandedValue = expandedValue where !explode {
        return "\(expandedVariable)=\(expandedValue)"
      }

      return expandedValue
    }

    return nil
  }
}

/// RFC6570 (3.2.9) Form-Style Query Continuation: {&var}
class FormStyleQueryContinuation : BaseOperator, Operator {
  var op: Character? { return "&" }
  var prefix: String { return "&" }
  override var joiner: String { return "&" }

  override func expand(value value: String) -> String {
    return value.percentEncoded()
  }

  override func expand(variable variable: String, value: String, prefix: Int?) -> String {
    let expandedValue = super.expand(variable: variable, value: value, prefix: prefix)
    return "\(variable)=\(expandedValue)"
  }

  override func expand(variable variable: String, value: [AnyObject], explode: Bool) -> String? {
    let joiner = explode ? self.joiner : ","
    let expandedValue = value.map {
      let expandedValue = self.expand(value: "\($0)")

      if explode {
        return "\(variable)=\(expandedValue)"
      }

      return expandedValue
    }.joinWithSeparator(joiner)

    if !explode {
      return "\(variable)=\(expandedValue)"
    }

    return expandedValue
  }

  override func expand(variable variable: String, value: [String:AnyObject], explode: Bool) -> String? {
    let expandedValue = super.expand(variable: variable, value: value, explode: explode)

    if let expandedValue = expandedValue where !explode {
      return "\(variable)=\(expandedValue)"
    }

    return expandedValue
  }
}

class Scanner {
  var content: String

  init(content: String) {
    self.content = content
  }

  var isEmpty: Bool {
    return content.isEmpty
  }

  func scan(until until: Character) -> String {
    let parts = content.characters.split(until, maxSplit: 1, allowEmptySlices: true).map(String.init)

    if parts.count == 2 {
      content = parts[1]
    } else {
      content = ""
    }

    return parts[0]
  }
}