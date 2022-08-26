//
//  Etc+Hashable.swift
//  ProbTh
//
//  Created by sbond75 on 8/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

extension Set: Hashable, Equatable {
    static func == (lhs: Set, rhs: Set) -> Bool {
        lhs.set == rhs.set
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(set)
    }
}
