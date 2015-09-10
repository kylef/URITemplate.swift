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
  // MARK: Template

  func testTemplate() {
    let uri = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual(uri.template, "{scheme}://{hostname}/")
  }

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

  // MARK: Hashable

  func testHashValue() {
    let template1 = URITemplate(template:"{scheme}://{hostname}/")
    let template2 = URITemplate(template:"{scheme}://{hostname}/")
    XCTAssertEqual(template1.hashValue, template2.hashValue)
  }

  // MARK: StringLiteralConvertible

  func testStringLiteralConvertible() {
    let literalTemplate:URITemplate = "{scheme}://{hostname}/"
    let template = URITemplate(template:"{scheme}://{hostname}/")

    XCTAssertEqual(literalTemplate, template)
  }
}
