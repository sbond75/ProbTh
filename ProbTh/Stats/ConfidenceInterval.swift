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
    // n is "at least" the given value.
    static func n(suchThatPlusOrMinusIsNoWiderThan plusOrMinus: R, atLevel level: R, givenStdev stdev: R) -> Int {
        return Int(ceil(ℝtoDouble(n(suchThatPlusOrMinusIs: plusOrMinus, atLevel: level, givenStdev: stdev))))
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
