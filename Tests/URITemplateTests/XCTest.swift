import Foundation
import XCTest
import Spectre
import URITemplate


public func testURITemplate() {
  describe("URI Template") {
    $0.it("exposes the template as a property") {
      let uri = URITemplate(template:"{scheme}://{hostname}/")
      try expect(uri.template) == "{scheme}://{hostname}/"
    }

    $0.it("is printable") {
      let template = URITemplate(template:"{scheme}://{hostname}/")
      try expect("\(template)") == "{scheme}://{hostname}/"
    }

    $0.describe("Equatable") {
      $0.it("compares two equal templates") {
        let template1 = URITemplate(template:"{scheme}://{hostname}/")
        let template2 = URITemplate(template:"{scheme}://{hostname}/")
        try expect(template1) == template2
      }

      $0.it("compares two different templates") {
        let template1 = URITemplate(template:"{scheme}://{hostname}/")
        let template2 = URITemplate(template:"{scheme}://{hostname}{path}")
        try expect(template1) != template2
      }
    }

    $0.it("has a hashValue") {
      let template1 = URITemplate(template:"{scheme}://{hostname}/")
      let template2 = URITemplate(template:"{scheme}://{hostname}/")
      try expect(template1.hashValue) == template2.hashValue
    }

    $0.it("is StringLiteralConvertible") {
      let literalTemplate:URITemplate = "{scheme}://{hostname}/"
      let template = URITemplate(template:"{scheme}://{hostname}/")

      try expect(literalTemplate) == template
    }

    $0.describe("expansion", closure: testExpansion)
    $0.describe("variables", closure: testVariables)
    $0.describe("integration", closure: testCases)
  }
}


class URITemplateTests: XCTestCase {
  func testRunURITemplate() {
    testURITemplate()
  }
}
