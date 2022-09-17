//
//  AxiomsOfProbability.swift
//  ProbTh
//
//  Created by sbond75 on 8/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import Bow
import BowGeneric

// Set of outcomes "Ω"
class SampleSpace: Set, Theory {
    var properties: [Property] = []
}
typealias omega = SampleSpace
typealias Ω = omega

// Set of events "ℱ" ("curly F")
// An event is a subset of the SampleSpace.
class EventSpace: Set, Theory {
    override init(_ members: Set.SetT) {
        super.init(members)
    }
    
    init(_ set: Set) {
        super.init(set.set)
    }
    
    var properties: [Property] = [
        #"for all A ∈ F, A ⊆ Ω"# // "A ⊆ Ω is a collection of possible outcomes of an experiment" and is a superset of F.
        // Properties of F:
        , #"∅ ∈ F"#
        , #"A ∈ F ⇒ Ω \ A ∈ F"#
        , #"A1, A2, . . . ∈ F ⇒ ∪_i A_i ∈ F"#
        // An EventSpace has these additional properties as a result:
        , #"If A ⊆ B ⇒ P(A) ≤ P(B)"#
        , #"P(A ∩ B) ≤ min(P(A), P(B))"#
        , #"P(A ∪ B) ≤ P(A) + P(B)"# // "(Union Bound)"
        , #"P(Ω \ A) = 1 − P(A)"#
        , #"If A_1, . . . , A_k are a set of disjoint events such that ∪_{i=1}^k A_i = Ω, then \sum_{i=1}^k P(A_k) = 1"# // "(Law of Total Probability)"
    ].map{Property(stringLiteral: $0)}
}
typealias F = EventSpace
typealias ℱ = F

// Real numbers //
//typealias R = NSDecimalNumber
typealias R = Decimal // https://developer.apple.com/documentation/foundation/decimal , base-10 number
typealias ℝ = R

//typealias R = Double
//func ℝtoDouble(_ ℝ: ℝ) -> Double {
//    return ℝ
//}

func ℝtoDouble(_ ℝ: ℝ) -> Double {
    return NSDecimalNumber(decimal: ℝ).doubleValue
}

func doubleToℝ(_ double: Double) -> ℝ {
    return Decimal(double)
}
func intToℝ(_ int: Int) -> ℝ {
    return Decimal(int)
}
func stringToℝ(_ string: String) -> ℝ {
    return Decimal(string: string)!
}
// //

// General ℝ functions
extension ℝ {
    var integerAndFractionParts: (ℝ, ℝ) {
        let value = self
        let doubleValue = ℝtoDouble(value)
        let integerPart = floor(doubleValue)
        return (ℝ(integerPart), ℝ(doubleValue - integerPart))
    }
}

typealias P = Function1<ℱ, __0iTo1i>

class ProbabilityMeasure: Theory {
    var properties: [Property] = [
        #"for all A ∈ F, P(A) ≥ 0"#
        , #"P(Ω) = 1"#
        , #"If A1, A2, . . . are disjoint events (i.e., A_i ∩ A_j = ∅ whenever i \neq j), then P(∪_i A_i) = \sum_{i} P(A_i)"#
    ].map{Property(stringLiteral: $0)}
    
    var P: P!
}


// An event is a set since it is defined as a "subset of Ω"
class Event: Set, Theory {
    init(members: Set.SetT, Ω omega: Ω) {
        self.Ω = omega
        super.init(members)
    }
    
    var properties: [Property] = [
        #"self ⊆ Ω"#
    ]
    
    func complement() -> Event {
        fatalError() // TODO: implement
//        return Ω.set.intersection(self.set)
    }
    
    let Ω: Ω
}
