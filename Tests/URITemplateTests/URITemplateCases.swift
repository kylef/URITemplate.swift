import Foundation
import Spectre
import PathKit
import URITemplate


let testCases: ((ContextType) -> Void) = {
  let files = [
    "extended-tests",
    "spec-examples-by-section",
    "spec-examples"
  ]

  let supportedExpansionLevel = 4
  let supportedExtractionLevel = 3

  for file in files {
    $0.describe("Test Case File \(file)") {
      let path = Path(#file) + ".." + "Cases" + "\(file).json"
      let content = try! JSONSerialization.jsonObject(with: try! path.read(), options: []) as! [String: AnyObject]
      let suites = content
        .map { Suite(name: $0.0, testSuite: $0.1 as! [String: AnyObject]) }

      for suite in suites {
        $0.describe("Suite \(suite.name)") {
          let expansionDescribe = (supportedExpansionLevel >= suite.level) ? $0.describe : $0.xdescribe
          expansionDescribe("expansion") {
            for (index, testcase) in suite.cases.enumerated() {
              $0.it("can expand case \(index + 1) (\(testcase.uriTemplate))") {
                let expanded = testcase.uriTemplate.expand(suite.variables)
                try expect(testcase.expected.contains(expanded)).to.beTrue()
              }
            }
          }

          let extractionDescribe = (supportedExtractionLevel >= suite.level) ? $0.describe : $0.xdescribe
          extractionDescribe("extraction") {
            for (index, testcase) in suite.cases.enumerated() {
              $0.describe("can extract case \(index + 1) (\(testcase.uriTemplate))") {
                let template = testcase.uriTemplate

                for (index, uri) in testcase.expected.enumerated() {
                  $0.it("URI \(index + 1)") {
                    if let variables = template.extract(uri) {
                      var expectedVariables: [String: String] = [:]

                      for variable in template.variables {
                        if let value:AnyObject = variables[variable] as AnyObject? {
                          expectedVariables[variable] = "\(value)"
                        } else {
                          throw failure("Missing Variable \(variable) from `\(uri)` with template `\(template)`")
                        }
                      }

                      try expect(variables as NSDictionary) == expectedVariables as NSDictionary
                    } else {
                      throw failure("Extracted no match template: \(template) with uri: \(uri)")
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

// MARK: Suite Structures

struct Suite {
  let name:String
  let variables:Dictionary<String, AnyObject>
  let cases:[Case]
  let level:Int

  init(name:String, testSuite:Dictionary<String, AnyObject>) {
    self.name = name
    variables = testSuite["variables"] as! Dictionary<String, AnyObject>
    let testcases = testSuite["testcases"] as! [[AnyObject]]
    cases = testcases.map { Case(object:$0) }

    if let testLevel = testSuite["level"] as? Int {
      level = testLevel
    } else {
      level = 4
    }
  }
}

struct Case {
  let template:String
  let expected:[String]

  init(object:[AnyObject]) {
    template = object[0] as! String
    if let expected = object[1] as? [String] {
      self.expected = expected
    } else {
      expected = [object[1] as! String]
    }
  }

  var uriTemplate:URITemplate {
    return URITemplate(template:template)
  }
}
