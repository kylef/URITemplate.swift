URITemplate
===========

[![Build Status](http://img.shields.io/travis/kylef/URITemplate.swift/master.svg?style=flat)](https://travis-ci.org/kylef/URITemplate.swift)

Swift implementation of URI Template ([RFC6570](https://tools.ietf.org/html/rfc6570)).

## Example

```swift
let template = URITemplate(template: "https://api.github.com/repos/{owner}/{repo}/")
let url = template.expand(["owner": "kylef", "repo": "URITemplate.swift"])
let variables = template.variables()

// url = "https://api.github.com/repos/kylef/URITemplate.swift/"
// variables = ["owner", "repo"]
```

## License

Stencil is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
