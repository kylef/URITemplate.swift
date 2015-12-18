//
//  URITemplateExtractTests.swift
//  URITemplate
//
//  Created by Kyle Fuller on 26/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation
import XCTest
import URITemplate

class URITemplateExtractTests: XCTestCase {
  func testBasicStringExtract() {
    let template = URITemplate(template:"{variable}")
    let values = template.extract("value")

    XCTAssertEqual(values!, ["variable": "value"])
  }

  func testHandlesCompositeValues() {
    let template = URITemplate(template:"https://api.github.com/repos/{owner}/{repo}/")
    XCTAssertEqual(template.extract("https://api.github.com/repos/kylef/PathKit/")!, ["owner":"kylef", "repo":"PathKit"])
  }

  func testMatchWithoutVariables() {
    let template = URITemplate(template:"https://api.github.com/repos/kylef/URITemplate")
    XCTAssertEqual(template.extract("https://api.github.com/repos/kylef/URITemplate")!.count, 0)
  }

  func testNoVariablesNoMatch() {
    let template = URITemplate(template:"https://api.github.com/repos/kylef/URITemplate")
    XCTAssertNil(template.extract("https://api.github.com/repos/kylef/PatkKit"))
  }

  func testVariablesNoMatch() {
    let template = URITemplate(template:"https://api.github.com/repos/{owner}")
    XCTAssertNil(template.extract("https://api.github.com/repos/kylef/WebLinking"))
  }
}
