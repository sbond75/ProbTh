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

infix operator ∪: BitwiseShiftPrecedence
func ∪(lhs: Set, rhs: Set) -> Set {
    return Set(lhs.set.union(rhs.set))
}

infix operator ∩: BitwiseShiftPrecedence
func ∩(lhs: Set, rhs: Set) -> Set {
    return Set(lhs.set.intersection(rhs.set))
}

// Aka "disjoint"
func mutuallyExclusive(_ lhs: Set, _ rhs: Set) -> Bool {
    let retval = (lhs ∩ rhs) == emptySet
    assert(retval == lhs.set.isDisjoint(with: rhs.set)) // https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html -- + tip: can also use isSuperset(of:) , isSubset(of:) , isStrictSubset(of:) or isStrictSuperset(of:)
    return retval
}

let emptySet = Set([])
//let ∅ = emptySet

let makeTrivialEventSpace: (Ω) -> ℱ = {omega in assert(omega != emptySet); return ℱ([emptySet, omega])} // trivial event space: is "the simplest event space is the trivial event space F = {∅, Ω}."

let sixSidedFairDie = SampleSpace([1,2,3,4,5,6])
func example1() {
    let A = Set([2,4,6])
    let B = Set([1,2,3])
    assert(A ∩ B == Set([2]))
    assert(A ∪ B == Set([1,2,3,4,6]))
}

//example1()

RunLoop.current.run()
