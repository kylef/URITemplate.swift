//
//  URITemplateCases.swift
//  URITemplate
//
//  Created by Kyle Fuller on 26/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation
import XCTest
import URITemplate

// MARK: Tests

func testExpansion(suite:Suite, testcase:Case) {
  let expanded = testcase.uriTemplate.expand(suite.variables)
  XCTAssertTrue(contains(testcase.expected, expanded), "\(testcase.template). \(testcase.expected[0]) !~ \(expanded)")
}

func testExtraction(suite:Suite, testcase:Case) {
  let template = testcase.uriTemplate

  for uri in testcase.expected {
    let variables = template.extract(uri)
    var expectedVariables = Dictionary<String, String>()
    for variable in template.variables {
      if let value:AnyObject = variables[variable] as AnyObject? {
        expectedVariables[variable] = "\(value)"
      } else {
        XCTAssert(false, "Missing Variable \(variable) from `\(uri)` with template `\(template)`")
      }
    }

    XCTAssertEqual(variables as NSDictionary, expectedVariables as NSDictionary, "\(template)")
  }
}

@objc class URITemplateCasesTests : XCTestCase {
  let files = [
    "extended-tests",
    "spec-examples-by-section",
    "spec-examples"
  ]

  let supportedExpansionLevel = 4
  let supportedExtractionLevel = 3

  override class func testInvocations() -> [AnyObject] {
    let tests = URITemplateCasesTests()
    var invocations = [AnyObject]()

    for suite in tests.suites() {
      for (index, testcase) in enumerate(suite.cases) {
        if tests.supportedExpansionLevel >= suite.level {
          invocations.append(addTest("\(suite.name) Case \(index) Expansion") {
            testExpansion(suite, testcase)
          })
        }

        if tests.supportedExtractionLevel >= suite.level {
          invocations.append(addTest("\(suite.name) Case \(index) Extraction") {
            testExtraction(suite, testcase)
          })
        }
      }
    }

    return invocations
  }

  class func addTest(name:String, closure:() -> ()) -> AnyObject {
    let block : @objc_block (AnyObject!) -> () = { (instance : AnyObject!) -> () in
      closure()
    }

    let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
    let selectorName = name.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions(0), range: nil)
    let selector = Selector(selectorName)
    let method = class_getInstanceMethod(self, "example") // No @encode in swift, creating a dummy method to get encoding
    let types = method_getTypeEncoding(method)
    let added = class_addMethod(self, selector, imp, types)
    assert(added, "Failed to add `\(name)` as `\(selector)`")

    return self.testCaseWithSelector(selector).invocation
  }

  func example() { /* See addTest() */ }

  // MARK:

  func suites() -> [Suite] {
    let bundle = NSBundle(forClass:object_getClass(self))
    let urls = files.map { file -> NSURL in
      bundle.URLForResource(file, withExtension: "json")!
    }

    return loadSuites(urls)
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
    variables = testSuite["variables"] as Dictionary<String, AnyObject>
    let testcases = testSuite["testcases"] as [[AnyObject]]
    cases = testcases.map { Case(object:$0) }

    level = 4
    if let testLevel = testSuite["level"] as? Int {
      level = testLevel
    }
  }
}

struct Case {
  let template:String
  let expected:[String]

  init(object:[AnyObject]) {
    template = object[0] as String
    if let expected = object[1] as? [String] {
      self.expected = expected
    } else {
      expected = [object[1] as String]
    }
  }

  var uriTemplate:URITemplate {
    return URITemplate(template:template)
  }
}

// MARK: Loading suite methods

func loadFixture(URL:NSURL) -> Dictionary<String, AnyObject> {
  let data = NSData(contentsOfURL: URL)!
  var error:NSError?
  let object: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
  assert(error == nil)
  return object as Dictionary<String, AnyObject>
}

func loadSuites(urls:[NSURL]) -> [Suite] {
  var suites = [Suite]()

  for url in urls {
    for (key, value) in loadFixture(url) {
      if let testsuite = value as? Dictionary<String, AnyObject> {
        suites.append(Suite(name:key, testSuite:testsuite))
      }
    }
  }

  return suites
}
