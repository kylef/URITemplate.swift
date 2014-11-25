URITemplate
===========

Swift implementation of URI Template (RFC6570).

## Example

```swift
let template = URITemplate(template: "http://{domain}/")
template.expand(["domain": "kylefuller.co.uk"])
```