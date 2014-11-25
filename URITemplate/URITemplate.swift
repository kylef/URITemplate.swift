//
//  URITemplate.swift
//  URITemplate
//
//  Created by Kyle Fuller on 25/11/2014.
//  Copyright (c) 2014 Kyle Fuller. All rights reserved.
//

import Foundation

public struct URITemplate : Printable, Equatable {
  let template:String

  public init(template:String) {
    self.template = template
  }

  public var description:String {
    return template
  }
}

public func ==(lhs:URITemplate, rhs:URITemplate) -> Bool {
  return lhs.template == rhs.template
}
