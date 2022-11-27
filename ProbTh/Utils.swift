//
//  Utils.swift
//  ProbTh
//
//  Created by sbond75 on 11/27/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

func equalByEpsilon(_ a: Double, _ b: Double, epsilon: Double) -> Bool {
    return abs(a - b) < epsilon
}

func equalByEpsilon(_ a: R, _ b: R, epsilon: R) -> Bool {
    return abs(a - b) < epsilon
}
