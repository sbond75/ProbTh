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

//QQPlot().plot(sample: Sample([2.5, 3.7, 4.9, 6.4, 7.5]))

//QQPlot().plot(sample: Sample([1, 2, 3, 6, 9, 12, 15, 18, 19, 20]))

//QQPlot().plot(sample: Sample([4.1,1.8, 3.2, 1.9, 4.6, 2.0,4.5,3.9, 4.3, 2.3,
//3.8,1.9, 4.6, 1.8, 4.7, 1.8,4.6,1.9, 3.5, 4.0,
//3.7,3.7, 4.3, 3.6, 3.8, 3.8,3.8,2.5, 4.5, 4.1,
//3.7,3.8, 3.4, 4.0, 2.3, 4.4,4.1,4.3, 3.3, 2.0
//]))
// TODO ^broken? should look like /Volumes/MyTestVolume/Sp1Semester1_Vanderbilt_University/Stats/Documents/Probability Plot Template (1).xlsx

//let res = Poisson(items: 15, per: 10).p(XIsGreaterThan: 1)

//let res2 = Bin(numberOfTrials: 10, successRate: Exp(rate: 0.25).p(TIsLessThan: 3).ℝ_0to1).p(XIsGreaterThan: -1)

let res3 = U(a: 0,b: 20).p(givenValueIsLessThanX: 5, andXIsLessThan: 15)

let res4 = Bin(numberOfTrials: 3000,successRate: 1.0/1000).p(XIsExactly: 0)

//initPython()

RunLoop.current.run()

//Py_Finalize()

//var X=SampleOrPopulation_givenValues(nOrN: nil, mean: 61, variance: nil); var Y = SampleOrPopulation_givenValues(nOrN: nil, mean: 26, variance: nil); print((X + -9*Y).mean)

//X=SampleOrPopulation_givenValues(nOrN: nil, mean: nil, stdev: 7); Y = SampleOrPopulation_givenValues(nOrN: nil, mean: nil, stdev: 4); print((X + -9*Y).stdev)
