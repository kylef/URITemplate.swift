//
//  URITemplateVariablesTests.swift
//  URITemplate
//
//  Created by Kyle Fuller on 26/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation
import XCTest
import URITemplate

// MARK: Variables

class URITemplateVariablesTests : XCTestCase {
  func testVariables() {
    let template = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual(template.variables, ["scheme", "hostname"])
  }

  func testMultipleVariablesInExpression() {
    let template = URITemplate(template:"test/{a,b}")
    XCTAssertEqual(template.variables, ["a", "b"])
  }

  func testReservedVariablesInExpression() {
    let template = URITemplate(template:"test/{+reserved}")
    XCTAssertEqual(template.variables, ["reserved"])
  }

  func testLabelVariablesInExpression() {
    let template = URITemplate(template:"test/{.label}")
    XCTAssertEqual(template.variables, ["label"])
  }

  func testFragmentVariablesInExpression() {
    let template = URITemplate(template:"test/{#fragment}")
    XCTAssertEqual(template.variables, ["fragment"])
  }

  func testPathSegmentVariablesInExpression() {
    let template = URITemplate(template:"test/{/segment}")
    XCTAssertEqual(template.variables, ["segment"])
  }

  func testPathParameterVariablesInExpression() {
    let template = URITemplate(template:"test/{;parameter}")
    XCTAssertEqual(template.variables, ["parameter"])
  }

  func testFormStyleQueryVariablesInExpression() {
    let template = URITemplate(template:"test/{?query}")
    XCTAssertEqual(template.variables, ["query"])
  }

  func testFormStyleQueryContinuationVariablesInExpression() {
    let template = URITemplate(template:"test/{&continuation}")
    XCTAssertEqual(template.variables, ["continuation"])
  }

  func testHandlesCompositeValues() {
    let template = URITemplate(template:"{/list*}")
    XCTAssertEqual(template.variables, ["list"])
  }

  func testMixedQueryParameterVariables() {
    let template = URITemplate(template:"{scheme}://{hostname}/endpoint.json{?query,list*}")
    XCTAssert(template.variables.contains("hostname"))
  }
}
