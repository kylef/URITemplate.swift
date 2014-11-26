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

class URITemplateCasesTests : XCTestCase {
  let files = [
    "extended-tests",
//    "negative-tests",
    "spec-examples-by-section",
    "spec-examples"
  ]

  func loadFixture(named:String) -> Dictionary<String, AnyObject> {
    let bundle = NSBundle(forClass:object_getClass(self))
    let path = bundle.URLForResource(named, withExtension: "json")!
    let data = NSData(contentsOfURL: path)!
    var error:NSError?
    let object: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
    assert(error == nil)
    return object as Dictionary<String, AnyObject>
  }

  func testExpansion() {
    let supportedLevel = 3
    let fixtures = files.map(loadFixture)

    for fixture in fixtures {
      for (name, value) in fixture {
        let testsuite = value as Dictionary<String, AnyObject>
        let variables = testsuite["variables"] as Dictionary<String, AnyObject>
        let testcases = testsuite["testcases"] as [AnyObject]
        var level = 4
        if let testLevel = testsuite["level"] as? Int {
          level = testLevel
        }

        for testcase in testcases {
          if supportedLevel >= level {
            let template = testcase[0] as String
            let uritemplate = URITemplate(template: template)
            let expanded = uritemplate.expand(variables)

            if let expected = testcase[1] as? String {
              XCTAssertEqual(expanded, expected, "\(template)")
            } else if let expected = testcase[1] as? [String] {
              XCTAssertTrue(contains(expected, expanded), "\(template)")
            }
          }
        }
      }
    }
  }
}
