//
//  ConditionalProb.swift
//  ProbTh
//
//  Created by sbond75 on 8/20/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// Conditional probability and independence

import Foundation

// "Let B be an event with non-zero probability. The conditional probability of any event A given B is defined as":
func condProb(P: P, A: Event, given B: Event) -> ℝ {
    return P.invoke(ℱ(A ∩ B)).ℝ_0to1 / P.invoke(ℱ(B)).ℝ_0to1
}

// Returns true if events A and B are independent.
func indep(P: P, A: Event, B: Event) -> Bool {
    return P.invoke(ℱ(A ∩ B)).ℝ_0to1 == P.invoke(ℱ(A)).ℝ_0to1 * P.invoke(ℱ(B)).ℝ_0to1
    // "(or equivalently, P(A|B) = P(A))" (where `|` is `condProb`).
}
