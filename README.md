URITemplate
===========

[![Build Status](http://img.shields.io/travis/kylef/URITemplate.swift/master.svg?style=flat)](https://travis-ci.org/kylef/URITemplate.swift)

Swift implementation of URI Template (RFC6570).

## Example

```swift
let template = URITemplate(template: "http://{domain}/")
template.expand(["domain": "kylefuller.co.uk"])
```

## License

Stencil is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
