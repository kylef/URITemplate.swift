import Spectre
import URITemplate


let testVariables: ((ContextType) -> Void) = {
  $0.it("can extract variables") {
    let template = URITemplate(template:"{scheme}://{hostname}/")
    try expect(template.variables) == ["scheme", "hostname"]
  }

  $0.it("can extract multiple variables in an expression") {
    let template = URITemplate(template:"test/{a,b}")
    try expect(template.variables) == ["a", "b"]
  }

  $0.it("can extract reserved variables in an expression") {
    let template = URITemplate(template:"test/{+reserved}")
    try expect(template.variables) == ["reserved"]
  }

  $0.it("can extract label variables in an expression") {
    let template = URITemplate(template:"test/{.label}")
    try expect(template.variables) == ["label"]
  }

  $0.it("can extract fragment variables in an expression") {
    let template = URITemplate(template:"test/{#fragment}")
    try expect(template.variables) == ["fragment"]
  }

  $0.it("can extract segment variables in an expression") {
    let template = URITemplate(template:"test/{/segment}")
    try expect(template.variables) == ["segment"]
  }

  $0.it("can extract parameter variables in an expression") {
    let template = URITemplate(template:"test/{;parameter}")
    try expect(template.variables) == ["parameter"]
  }

  $0.it("can form style query variables in an expression") {
    let template = URITemplate(template:"test/{?query}")
    try expect(template.variables) == ["query"]
  }

  $0.it("can extract form style query continuation variables in an expression") {
    let template = URITemplate(template:"test/{&continuation}")
    try expect(template.variables) == ["continuation"]
  }

  $0.it("can extract composite values") {
    let template = URITemplate(template:"{/list*}")
    try expect(template.variables) == ["list"]
  }

  $0.it("can extract mixed query/parameter variables") {
    let template = URITemplate(template:"{scheme}://{hostname}/endpoint.json{?query,list*}")
    try expect(template.variables.contains("hostname")).to.beTrue()
  }
}
