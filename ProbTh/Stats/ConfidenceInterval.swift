//
//  ConfidenceInterval.swift
//  ProbTh
//
//  Created by sbond75 on 10/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import PythonKit

protocol CI: CustomStringConvertible {
    var lhs: R { get }
    var plusOrMinus: R { get }
    var level: R { get }
    var item: String { get }
}

struct GeneralCI: CI {
    var lhs: R
    var plusOrMinus: R
    var level: R
    var item: String
    
    var msg: String { "We are \(level * 100)% confident that \(item) is within \(lhs) ± \(plusOrMinus)" }
    
    // MARK: CustomStringConvertible
    
    var description: String { msg }
}

class ConfidenceInterval: CI {
    // (NOTE: `SampleOrPopulation` here is only used as a sample but with its stdev treated as σ (population stdev). The `SampleOrPopulation` is treated mostly as a `Sample` because confidence intervals are supposed to be estimating things about the *population*, such as the mean of the population.)
    // NOTE: SampleOrPopulation is assumed to contain X̄ and σ unless you specify true for the S parameter which will make it use `sample`'s stdev as sample stdev instead of population stdev.
    // NOTE: If n <= 30 in the sample, then it is a small sample, so the t-distribution will be used if you provide true for S (since t-distribution requires sample stdev only).
    init(sample: SampleOrPopulation, level: R, sampleStdev: Bool = false) {
        self.sample = sample
        self.level = level
        self.sampleStdev = sampleStdev
    }
    
    static func zscore(forLevel level: R, oneSided: Bool = false) -> R {
        doubleToℝ(Normal.Z(alpha: ℝtoDouble((1 - level) / (oneSided ? 1 : 2))))
    }
    
    static func level(forZscore zScore: R, oneSided: Bool) -> R {
        doubleToℝ(Normal.percentile(zscore: ℝtoDouble(zScore)))
    }
    static func alpha(forZscore zScore: R, oneSided: Bool) -> R {
        -((oneSided ? 1 : 2) * doubleToℝ(Normal.percentile(zscore: ℝtoDouble(zScore))) - 1)
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
    
    // Confidence interval for a proportion using Agresti-Coull. `denominator` is "n" and `numerator`/`denominator` is "p" (all without Agresti-Coull modification since this function does that for you).
    static func agrestiCoullCIForProportion(numerator: Int, denominator: Int, atLevel level: R) -> CI {
        let pTilde = intToℝ(numerator + 2) / intToℝ(denominator + 4)
        let nTilde = intToℝ(denominator + 4)
        return GeneralCI(lhs: pTilde, plusOrMinus: ConfidenceInterval.zscore(forLevel: level, oneSided: false) * sqrt((pTilde * (1-pTilde)) / nTilde), level: level, item: "p")
    }
    // Finds the confidence level of the claim "more than p" of some item satisfy the conditions associated with `numerator`/`denominator`.
    // Example from textbook: "During a recent drought, a water utility in a certain town sampled 100 residential water bills
    // and found that 73 of the residences had reduced their water consumption over that of the
    // previous year."
    // "Someone claims that more than 70% of residences reduced their water consumption.
    // With what level of confidence can this statement be made?"
    // This function answers this question above when called like so: `ConfidenceInterval.agrestiCoullLevelForProportion(moreThan: 0.7, numerator: 73, denominator: 100)`
    static func agrestiCoullLevelForProportion(moreThan p: R, numerator: Int, denominator: Int) -> __0iTo1i {
        let pTilde = intToℝ(numerator + 2) / intToℝ(denominator + 4)
        let nTilde = intToℝ(denominator + 4)
        return __0iTo1i(ℝ_0to1: ConfidenceInterval.level(forZscore: (-(p - pTilde)) / sqrt((pTilde * (1-pTilde)) / nTilde), oneSided: true))
    }
    
    var lowerConfidenceBound: R {
        xBar - ConfidenceInterval.zscore(forLevel: level, oneSided: true) * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }
    var upperConfidenceBound: R {
        xBar + ConfidenceInterval.zscore(forLevel: level, oneSided: true) * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }
    
    var xBar: R { sample.mean }
    var X̄: R { xBar }
    var sampleStdev: Bool = false
    
    var sample: SampleOrPopulation
    var smallSample: Bool { sample.nOrN <= 30 }
    var useTDist: Bool { smallSample && sampleStdev }
    var plusOrMinus: R {
        // Check for small sample
        var score: R!
        if useTDist {
            score = ConfidenceInterval.tDistribution(ν: sample.nOrN - 1, α: (1 - level) / 2)
        }
        else {
            score = ConfidenceInterval.zscore(forLevel: level)
        }
        
        // level = 1-alpha
        // => level - 1 = -alpha
        // => -level + 1 = alpha
        // => 1 - level = alpha
        return score * sample.stdev / sqrt(intToℝ(sample.nOrN))
    }

    // MARK: For reference
    
    var level: R
    
    // "We are (`level` * 100)% confident that μ is within X̄ ± `plusOrMinus`"
    var msg: String { "We are \(level * 100)% confident that \(item) is within \(xBar) ± \(plusOrMinus)" }
    
    var interval: (R, R) { (X̄ - plusOrMinus, X̄ + plusOrMinus) }
    
    // MARK: CI
    
    var lhs: R { xBar }
    
    var item: String { "μ" }
    
    // MARK: CustomStringConvertible
    
    var description: String { msg }
    
    // MARK: ConfidenceInterval with smallSample
    
    static func tDistribution(ν: Int, α: R) -> R {
        // https://stackoverflow.com/questions/19339305/python-function-to-get-the-t-statistic
        let res = pyrun("""
            from scipy import stats
            #Studnt, n=22,  2-tail
            #stats.t.ppf(1-0.025, df)
            # df=n-1=22-1=21
            # print (stats.t.ppf(1-0.025, 21))
            """, thenEval: "stats.t.ppf(1 - \(α), \(ν))")
        print("value from the t-table:", res ?? "nil")
        return doubleToℝ(Double(res!)!)
    }
}

//infix operator -: AdditionPrecedence
// TODO: implement the below (currently the below is not type checking)
//func -(lhs: ConfidenceInterval, rhs: ConfidenceInterval) -> ConfidenceInterval {
//    assert(lhs.level == rhs.level && lhs.sampleStdev == rhs.sampleStdev)
//    return ConfidenceInterval(sample: lhs.sample - rhs.sample, level: lhs.level, sampleStdev: lhs.sampleStdev)
//}
