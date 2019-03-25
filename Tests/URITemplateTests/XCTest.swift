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

    #if swift(>=4.0)
    $0.describe("Codable") {
      $0.it("decodes from a JSON representation") {
        // JSON adapted from https://api.github.com
        let jsonWithTemplates = """
        {
          "code_search_url": "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}",
          "commit_search_url": "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}",
          "issue_search_url": "https://api.github.com/search/issues?q={query}{&page,per_page,sort,order}",
          "repository_search_url": "https://api.github.com/search/repositories?q={query}{&page,per_page,sort,order}",
          "user_search_url": "https://api.github.com/search/users?q={query}{&page,per_page,sort,order}"
        }
        """.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        let templateDictionary = try jsonDecoder.decode([String: URITemplate].self, from: jsonWithTemplates)

        try expect(templateDictionary["commit_search_url"]) == URITemplate(template: "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}")
      }

      $0.it("encodes and decodes without any loss of information") {
        let templates = [
          "search": URITemplate(template: "https://example.com/search?q{query}{&page,per_page}"),
          "user": URITemplate(template: "https://example.com/users/{user_id}")
        ]
        let plistEncoder = PropertyListEncoder()
        let plistDecoder = PropertyListDecoder()

        let data = try plistEncoder.encode(templates)
        let decodedTemplates = try plistDecoder.decode([String: URITemplate].self, from: data)

        try expect(decodedTemplates) == templates
      }
    }
    #endif

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
