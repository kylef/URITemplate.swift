//
//  URITemplateTests.swift
//  URITemplateTests
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation
import XCTest
import URITemplate

class URITemplateTests: XCTestCase {
  // MARK: Printable

  func testPrintable() {
    let template = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual("\(template)", "{scheme}://{hostname}/")
  }

  // MARK: Equatable

  func testEquatable() {
    let template1 = URITemplate(template:"{scheme}://{hostname}/")
    let template2 = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual(template1, template2)
  }

  func testEquatableUnequalObjects() {
    let template1 = URITemplate(template:"{scheme}://{hostname}/")
    let template2 = URITemplate(template:"{scheme}://{hostname}{path}")
    XCTAssertNotEqual(template1, template2)
  }
}

// MARK: Variables

class URITemplateVariablesTests : XCTestCase {
  func testVariables() {
    let template = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual(template.variables(), ["scheme", "hostname"])
  }

  func testMultipleVariablesInExpression() {
    let template = URITemplate(template:"test/{a,b}")
    XCTAssertEqual(template.variables(), ["a", "b"])
  }

  func testReservedVariablesInExpression() {
    let template = URITemplate(template:"test/{+reserved}")
    XCTAssertEqual(template.variables(), ["reserved"])
  }

  func testLabelVariablesInExpression() {
    let template = URITemplate(template:"test/{.label}")
    XCTAssertEqual(template.variables(), ["label"])
  }

  func testFragmentVariablesInExpression() {
    let template = URITemplate(template:"test/{#fragment}")
    XCTAssertEqual(template.variables(), ["fragment"])
  }

  func testPathSegmentVariablesInExpression() {
    let template = URITemplate(template:"test/{/segment}")
    XCTAssertEqual(template.variables(), ["segment"])
  }

  func testPathParameterVariablesInExpression() {
    let template = URITemplate(template:"test/{;parameter}")
    XCTAssertEqual(template.variables(), ["parameter"])
  }

  func testFormStyleQueryVariablesInExpression() {
    let template = URITemplate(template:"test/{?query}")
    XCTAssertEqual(template.variables(), ["query"])
  }

  func testFormStyleQueryContinuationVariablesInExpression() {
    let template = URITemplate(template:"test/{&continuation}")
    XCTAssertEqual(template.variables(), ["continuation"])
  }
}
