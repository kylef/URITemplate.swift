URITemplate
===========

[![Build Status](http://img.shields.io/travis/kylef/URITemplate.swift/master.svg?style=flat)](https://travis-ci.org/kylef/URITemplate.swift)

Swift implementation of URI Template ([RFC6570](https://tools.ietf.org/html/rfc6570)).

## Example

### Expanding a URI Template

```swift
let template = URITemplate(template: "https://api.github.com/repos/{owner}/{repo}/")
let url = template.expand(["owner": "kylef", "repo": "URITemplate.swift"])
=> "https://api.github.com/repos/kylef/URITemplate.swift/"
```

### Determine which variables are in a template

```swift
let variables = template.variables()
=> ["owner", "repo"]
```

### Extract the variables used in a given URL

```swift
let variables = template.extract("https://api.github.com/repos/kylef/PathKit/")
=> ["owner":"kylef", "repo":"PathKit"]
```

## [RFC6570](https://tools.ietf.org/html/rfc6570)

The URITemplate library follows the [test suite](https://github.com/uri-templates/uritemplate-test).

The different functions inside URITemplate support different levels of RFC6570. Full level 4 support across all functions is desired and currently work in progress.

| Component   | Compliance     |
|:-----------:|:--------------:|
| `variables` | Full (Level 4) |
| `expand`    | Level 3        |
| `extract`   | Level 1        |

## License

URITemplate is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
