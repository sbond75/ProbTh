//
//  PMF.swift
//  ProbTh
//
//  Created by sbond75 on 8/20/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// Probability mass functions

import Foundation
import Bow

// "When a random variable X takes on a finite set of possible values (i.e., X is a discrete random
// variable), a simpler way to represent the probability measure associated with a random variable is
// to directly specify the probability of each value that the random variable can assume. In particular,
// a probability mass function (PMF) is a function pₓ : Ω → ℝ such that" "pₓ(x) = P (X = x)" where `=` is by definition.
typealias pₓ = Function1<Ω, __0iTo1i> // where ₓ is is X

class pₓ_props: Theory {
    var properties: [Property] = [
        #"0 ≤ pₓ(x) ≤ 1"#,
        #"\sum_{x ∈ Val(X)} pₓ(x) = 1"#, // Val() means the outputs of the `RandomVar` function.
        #"\sum_{x ∈ A} pₓ(x) = P(X ∈ A)"#
    ]
}
