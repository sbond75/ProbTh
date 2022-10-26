//
//  ConfidenceInterval.swift
//  ProbTh
//
//  Created by sbond75 on 10/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class ConfidenceInterval: CustomStringConvertible {
    // (NOTE: `SampleOrPopulation` here is only used as a sample. This is because confidence intervals are supposed to be estiminate the mean of the population.)
    init(sample: SampleOrPopulation, level: R) {
        self.sample = sample
        self.level = level
    }
    
    static func zscore(forLevel level: R, oneSided: Bool = false) -> R {
        doubleToℝ(Normal.Z(alpha: ℝtoDouble((1 - level) / (oneSided ? 1 : 2))))
    }
    
    // Returns unrounded version of `n` to meet the criteria given.
    static func n(suchThatPlusOrMinusIs plusOrMinus: R, atLevel level: R, givenStdev stdev: R) -> R {
        let temp = zscore(forLevel: level) * stdev / plusOrMinus
        return temp * temp
    }
    // For confidence intervals for proportions with Agresti-Coull
    static func nForProportion(suchThatPlusOrMinusIs plusOrMinus: R, atLevel level: R) -> R {
        let temp = zscore(forLevel: level) / plusOrMinus
        return (temp * temp) * 0.5 * (1 - 0.5) - 4
    }
    // For confidence intervals for proportions with Agresti-Coull. oldP is the one we started with, i.e. ((#successes + 2) / (n + 4))
    static func nTildeForProportion(suchThatPIsAtLeast p: R, atLevel level: R, oldP: R) -> R {
        let temp = zscore(forLevel: level, oneSided: true) / -(p - oldP)
        return (temp * temp) * oldP * (1 - oldP)
    }
    // n is "at least" the given value.
    static func n(suchThatPlusOrMinusIsNoWiderThan plusOrMinus: R, atLevel level: R, givenStdev stdev: R) -> Int {
        return Int(ceil(ℝtoDouble(n(suchThatPlusOrMinusIs: plusOrMinus, atLevel: level, givenStdev: stdev))))
    }
    static func nForProportion(suchThatPlusOrMinusIsNoWiderThan plusOrMinus: R, atLevel level: R) -> Int {
        return Int(ceil(ℝtoDouble(nForProportion(suchThatPlusOrMinusIs: plusOrMinus, atLevel: level))))
    }
    static func nForProportion(suchThatPIsAtLeast p: R, atLevel level: R, oldP: R) -> Int {
        return Int(ceil(ℝtoDouble(nTildeForProportion(suchThatPIsAtLeast: p, atLevel: level, oldP: oldP)))) - 4
    }
    static func howManyMoreForProportion(suchThatPIsAtLeast p: R, atLevel level: R, oldP: R, existingNTilde n: Int) -> Int {
        return nForProportion(suchThatPIsAtLeast: p, atLevel: level, oldP: oldP) - n
    }
    
    var lowerConfidenceBound: R {
        xBar - ConfidenceInterval.zscore(forLevel: level, oneSided: true) * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }
    var upperConfidenceBound: R {
        xBar + ConfidenceInterval.zscore(forLevel: level, oneSided: true) * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }
    
    var xBar: R { sample.mean }
    var X̄: R { xBar }
    
    var sample: SampleOrPopulation
    var plusOrMinus: R {
        // level = 1-alpha
        // => level - 1 = -alpha
        // => -level + 1 = alpha
        // => 1 - level = alpha
        ConfidenceInterval.zscore(forLevel: level) * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }

    // MARK: For reference
    
    var level: R
    
    // "We are (`level` * 100)% confident that μ is within X̄ ± `plusOrMinus`"
    var msg: String { "We are \(level * 100)% confident that μ is within \(xBar) ± \(plusOrMinus)" }
    
    var interval: (R, R) { (X̄ - plusOrMinus, X̄ + plusOrMinus) }
    
    // MARK: CustomStringConvertible
    
    var description: String { msg }
}
