//
//  URITemplateExpansionTests.swift
//  URITemplate
//
//  Created by Kyle Fuller on 26/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation
import XCTest
import URITemplate

class URITemplateExpansionTests: XCTestCase {
  func testBasicStringExpansion() {
    let template = URITemplate(template:"{name}")
    let expanded = template.expand(["name": "Kyle's"])
    XCTAssertEqual(expanded, "Kyle%27s")
  }

  func testReservedExpansion() {
    let template = URITemplate(template:"{+path}/here")
    let expanded = template.expand(["path": "/its"])
    XCTAssertEqual(expanded, "/its/here")
  }

  func testFragmentExpansion() {
    let template = URITemplate(template:"{#value}")
    let expanded = template.expand(["value": "Hello World!"])
    XCTAssertEqual(expanded, "#Hello%20World!")
  }

  func testLabelExpansion() {
    let template = URITemplate(template:"{.who}")
    let expanded = template.expand(["who": "kyle"])
    XCTAssertEqual(expanded, ".kyle")
  }

  func testPathStyleParameterExpansion() {
    let template = URITemplate(template:"{;who}")
    let expanded = template.expand(["who": "kyle"])
    XCTAssertEqual(expanded, ";who=kyle")
  }

  func testFormStyleQueryExpansion() {
    let template = URITemplate(template:"{?who}")
    let expanded = template.expand(["who": "kyle"])
    XCTAssertEqual(expanded, "?who=kyle")
  }

  func testFormStyleQueryContinuationExpansion() {
    let template = URITemplate(template:"{&who}")
    let expanded = template.expand(["who": "kyle"])
    XCTAssertEqual(expanded, "&who=kyle")
  }

  // MARK:

  func testPrefixExpansionTruncatesLength() {
    let template = URITemplate(template:"{name:1}")
    let expanded = template.expand(["name": "Kyle's"])
    XCTAssertEqual(expanded, "K")
  }

  func testBasicArrayJoiningExpansion() {
    let template = URITemplate(template:"{names}")
    let expanded = template.expand(["names": ["Kyle", "Katie"]])
    XCTAssertEqual(expanded, "Kyle,Katie")
  }

    func testExplodedArrayJoiningExpansion() {
        let template = URITemplate(template:"{.names*}")
        let expanded = template.expand(["names": ["Kyle", "Maxine"]])
        XCTAssertEqual(expanded, ".Kyle.Maxine")
    }
}
