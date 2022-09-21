//
//  RandomVar.swift
//  ProbTh
//
//  Created by sbond75 on 8/20/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// Random variables

import Foundation
import Bow

// "Consider an experiment in which we flip 10 coins, and we want to know the number of coins that
// come up heads. Here, the elements of the sample space Ω are 10-length sequences of heads and
// tails. For example, we might have w0 = hH, H, T, H, T, H, H, T, T, T i ∈ Ω. However, in practice,
// we usually do not care about the probability of obtaining any particular sequence of heads and tails.
// Instead we usually care about real-valued functions of outcomes, such as the number of heads that
// appear among our 10 tosses, or the length of the longest run of tails. These functions, under some
// technical conditions, are known as random variables."

// "More formally, a random variable X is a function X : Ω −→ ℝ" ("Technically speaking, not every function is not acceptable as a random variable. From a measure-theoretic
// perspective, random variables must be Borel-measurable functions. Intuitively, this restriction ensures that
// given a random variable and its underlying outcome space, one can implicitly define the each of the events
// of the event space as being sets of outcomes ω ∈ Ω for which X(ω) satisfies some property (e.g., the event
// {ω : X(ω) ≥ 3}).")
//
// "Typically, we will denote random
// variables using upper case letters X(ω) or more simply X (where the dependence on the random
// outcome ω is implied). We will denote the value that a random variable may take on using lower
// case letters x."
enum RandomVar {
    case Function(Function1<ℱ, ℝ>)
    case Bernoulli(/*p:*/ ℝ) // `p` is the success rate. (probability of a "success" or a "1" (whereas the probability of a "failure" or a "0" is therefore `1 - p`).)  // Alternate definition might be just a more general probability of a variable.. like `P(X=0) = 1 - p, P(X=1) = p` would be Bernoulli.
    
    func invoke(eventSpace: ℱ) -> ℝ {
        switch self {
        case let .Function(f):
            return f.invoke(eventSpace)
        case let .Bernoulli(p):
            // TODO: precondition(eventSpace can only have values 0 or 1 (1 for "success", 0 for "failure" -- in Bernoulli))
            return p
        }
    }
}

extension P {
    // Returns the probability that a random variable X equals k.
    // Works for a discrete random variable X.
    // Defined as: "P (X = k) := P ({ω : X(ω) = k})." (the right-hand side says that this is the probability that the outcome ω is k. Note that `:` means ω "has type" `X(ω)`.)
//    func p_X_eq_k(k: ℝ) -> __0iTo1i {
//
//    }
    
    // TODO: P (a ≤ X ≤ b) := P ({ω : a ≤ X(ω) ≤ b}).
    // for a continuous random variable X.
}
