//
//  Theory.swift
//  ProbTh
//
//  Created by sbond75 on 8/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class Property: ExpressibleByStringLiteral {
    var name: String?
    
    required init(stringLiteral value: String) {
        self.name = value
        // TODO: parse, etc.
    }
}

//extension Property: ExpressibleByStringLiteral {
//    init(stringLiteral value: String) {
//        self.name = value
//        // TODO: parse, etc.
//    }
//}

protocol Theory {
    var properties: [Property] { get }
}
