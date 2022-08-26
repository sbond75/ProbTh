//
//  main.swift
//  ProbTh
//
//  Created by sbond75 on 8/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// Based on https://cs229.stanford.edu/section/cs229-prob.pdf

import Foundation

class Set {
    typealias T = AnyHashable
    typealias SetT = Swift.Set<T>
    var set: SetT
    
    init(_ members: SetT) {
        set = members
    }
}

infix operator ∪
func ∪(lhs: Set, rhs: Set) -> Set {
    return Set(lhs.set.union(rhs.set))
}

infix operator ∩
func ∩(lhs: Set, rhs: Set) -> Set {
    return Set(lhs.set.intersection(rhs.set))
}

let emptySet = Set([])
//let ∅ = emptySet

let makeTrivialEventSpace: (Ω) -> ℱ = {omega in assert(omega != emptySet); return ℱ([emptySet, omega])} // trivial event space: is "the simplest event space is the trivial event space F = {∅, Ω}."
