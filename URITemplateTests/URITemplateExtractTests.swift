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

    XCTAssertEqual(values, ["variable": "value"])
  }
}
