import Spectre
import URITemplate


let testExpansion: ((ContextType) -> Void) = {
  $0.it("can expand basic template") {
    let template = URITemplate(template:"{name}")
    let expanded = template.expand(["name": "Kyle's"])
    try expect(expanded) == "Kyle%27s"
  }

  $0.it("can expand reserve extensions") {
    let template = URITemplate(template:"{+path}/here")
    let expanded = template.expand(["path": "/its"])
    try expect(expanded) == "/its/here"
  }

  $0.it("can expand fragments") {
    let template = URITemplate(template:"{#value}")
    let expanded = template.expand(["value": "Hello World!"])
    try expect(expanded) == "#Hello%20World!"
  }

  $0.it("can expand labels") {
    let template = URITemplate(template:"{.who}")
    let expanded = template.expand(["who": "kyle"])
    try expect(expanded) == ".kyle"
  }

  $0.it("can expand path style parameters") {
    let template = URITemplate(template:"{;who}")
    let expanded = template.expand(["who": "kyle"])
    try expect(expanded) == ";who=kyle"
  }

  $0.it("can expand form style query") {
    let template = URITemplate(template:"{?who}")
    let expanded = template.expand(["who": "kyle"])
    try expect(expanded) == "?who=kyle"
  }

  $0.it("can expand form style query continuation") {
    let template = URITemplate(template:"{&who}")
    let expanded = template.expand(["who": "kyle"])
    try expect(expanded) == "&who=kyle"
  }

  $0.it("truncates length during prefix expansion") {
    let template = URITemplate(template:"{name:1}")
    let expanded = template.expand(["name": "Kyle's"])
    try expect(expanded) == "K"
  }

  $0.describe("array joining") {
    $0.it("can join basic array") {
      let template = URITemplate(template:"{names}")
      let expanded = template.expand(["names": ["Kyle", "Katie"]])
      try expect(expanded) == "Kyle,Katie"
    }

    $0.it("can join exploded array") {
      let template = URITemplate(template:"{.names*}")
      let expanded = template.expand(["names": ["Kyle", "Maxine"]])
      try expect(expanded) == ".Kyle.Maxine"
    }
  }

  $0.describe("URL Encoding") {
    $0.it("encodes spaces") {
      let template = URITemplate(template:"{?postal}")
      let expanded = template.expand(["postal": "V3N 2R2"])
      try expect(expanded) == "?postal=V3N%202R2"
    }

    $0.it("encodes quotes") {
      let template = URITemplate(template:"{?test}")
      let expanded = template.expand(["test": "\"V3N\""])
      try expect(expanded) == "?test=%22V3N%22"
    }

    $0.it("encodes carrots") {
      let template = URITemplate(template:"{?test}")
      let expanded = template.expand(["test": "V3N^2R2"])
      try expect(expanded) == "?test=V3N%5E2R2"
    }
  }
}
