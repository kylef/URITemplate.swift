import Spectre
import URITemplate


let testExtract: ((ContextType) -> Void) = {
  $0.it("can extract a basic variable") {
    let template = URITemplate(template: "{variable}")
    let values = template.extract("value")

    try expect(values) == ["variable": "value"]
  }

  $0.it("handles composite values") {
    let template = URITemplate(template: "https://api.github.com/repos/{owner}/{repo}/")
    try expect(template.extract("https://api.github.com/repos/kylef/PathKit/")) == ["owner":"kylef", "repo":"PathKit"]
  }

  $0.it("matches without variables") {
    let template = URITemplate(template:"https://api.github.com/repos/kylef/URITemplate")
    try expect(template.extract("https://api.github.com/repos/kylef/URITemplate")?.count) == 0
  }

  $0.it("doesn't match with different URL without variables") {
    let template = URITemplate(template:"https://api.github.com/repos/kylef/URITemplate")
    try expect(template.extract("https://api.github.com/repos/kylef/PatkKit")).to.beNil()
  }

  $0.it("doesn't match with different URL with variables") {
    let template = URITemplate(template:"https://api.github.com/repos/{owner}")
    try expect(template.extract("https://api.github.com/repos/kylef/WebLinking")).to.beNil()
  }
}
