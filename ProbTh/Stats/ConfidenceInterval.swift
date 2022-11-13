//
//  ConfidenceInterval.swift
//  ProbTh
//
//  Created by sbond75 on 10/16/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import PythonKit
import SwiftyStats

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
    init(sample: SampleOrPopulation, level: R? = nil, sampleStdev: Bool = false, item: String = "μ") {
        self.sample = sample
        self.level_ = level
        self.sampleStdev = sampleStdev
        self.item = item
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
        if item == "μ" {
            return xBar - plusOrMinus(oneSided: true)
        }
        else if item == "σ" || item == "σ²" {
            return lowerOrUpperOneSidedConfidenceBound(upper: false)
        }
        else {
            fatalError()
        }
    }
    var upperConfidenceBound: R {
        if item == "μ" {
            return xBar + plusOrMinus(oneSided: true)
        }
        else if item == "σ" || item == "σ²" {
            return lowerOrUpperOneSidedConfidenceBound(upper: true)
        }
        else {
            fatalError()
        }
    }
    func lowerOrUpperOneSidedConfidenceBound(upper: Bool) -> R {
        assert(item == "σ" || item == "σ²")
        let oneSided = true
        
        // Section 5.8: Confidence intervals for variances and stdevs
        let numerator = intToℝ(n - 1) * sample.variance
        let testStatistic = (1 - level) / (oneSided ? 1 : 2)
        let degreeOfFreedom = n - 1
        do {
            let temp = numerator / doubleToℝ(try SSProbDist.ChiSquare.cdf(chi: ℝtoDouble(upper ? 1 - testStatistic : testStatistic), degreesOfFreedom: Double(degreeOfFreedom)))
            return (item == "σ²" ? temp : sqrt(temp))
        }
        catch let error {
            print("ConfidenceInterval.plusOrMinus(): error: \(error)")
            fatalError()
        }
    }
    
    var xBar: R { sample.mean }
    var X̄: R { xBar }
    var sampleStdev: Bool = false
    
    var n: Int { sample.nOrN }
    var sample: SampleOrPopulation
    var smallSample: Bool { sample.nOrN <= 30 }
    var useTDist: Bool { smallSample && sampleStdev }
    var plusOrMinus: R {
        plusOrMinus(oneSided: false)
    }
    func plusOrMinus(oneSided: Bool) -> R {
        if item == "μ" {
            // Check for small sample
            var score: R!
            if useTDist {
                score = ConfidenceInterval.tDistribution(ν: sample.nOrN - 1, α: (1 - level) / (oneSided ? 1 : 2))
            }
            else {
                score = ConfidenceInterval.zscore(forLevel: level, oneSided: oneSided)
            }
            
            // level = 1-alpha
            // => level - 1 = -alpha
            // => -level + 1 = alpha
            // => 1 - level = alpha
            return score * sample.stdev / sqrt(intToℝ(sample.nOrN))
        }
        else if item == "σ" || item == "σ²" {
            if oneSided {
                fatalError("Not a single number but two numbers")
            }
            else {
                fatalError("Not yet implemented") // might actually also be impossible..
            }
        }
        else {
            fatalError("Unknown test")
        }
    }

    // MARK: For reference
    
    var level: R {
        guard let level_ = level_ else {
            fatalError()
        }
        return level_
    }
    var level_: R?
    
    // For means: example: "We are (`level` * 100)% confident that μ is within X̄ ± `plusOrMinus`"
    var msg: String { "We are \(level * 100)% confident that \(item) is within \(lhs) ± \(plusOrMinus)" }
    
    var interval: (R, R) {
        if item == "μ" {
            return (X̄ - plusOrMinus, X̄ + plusOrMinus)
        }
        else if item == "σ" || item == "σ²" {
            fatalError("broken, todo")
            
            // Section 5.8: Confidence intervals for variances and stdevs
            let numerator = intToℝ(n - 1) * sample.variance
            let testStatistic = (1 - level) / 2
            let degreeOfFreedom = n - 1
            do {
                let interval = (numerator / doubleToℝ(try SSProbDist.ChiSquare.cdf(chi: ℝtoDouble(testStatistic), degreesOfFreedom: Double(degreeOfFreedom))),
                                numerator / doubleToℝ(try SSProbDist.ChiSquare.cdf(chi: ℝtoDouble(1 - testStatistic), degreesOfFreedom: Double(degreeOfFreedom))))
                return (item == "σ²" ? interval.0 : sqrt(interval.0), item == "σ²" ? interval.1 : sqrt(interval.1))
            }
            catch let error {
                print("ConfidenceInterval.interval: error: \(error)")
                fatalError()
            }
        }
        else {
            fatalError("Unknown test")
        }
    }
    
    // MARK: CI
    
    var lhs: R {
        if item == "μ" {
            return X̄
        }
        else if item == "σ" || item == "σ²" {
            return (item == "σ²" ? sample.variance : sample.stdev)
        }
        else {
            fatalError("Unknown test")
        }
    }
    
    var item: String
    
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


class DifferenceConfidenceInterval: CI {
    // MARK: CI
    
    var lhs: R { // Implement in child classes
        fatalError()
    }
    
    var plusOrMinus: R { plusOrMinus() }
    
    var level: R
    
    var item: String { // Implement in child classes
        fatalError()
    }
    
    var description: String { "We are \(level * 100)% confident that \(item) is within \(lhs) ± \(plusOrMinus)" }
    
    // MARK: DifferenceConfidenceInterval
    
    init() { // Implement in child classes
        level = 0
    }
    
    func plusOrMinus(oneSided: Bool = false) -> R {
        // Implement in child classes
        fatalError()
    }
    
    var lowerConfidenceBound: R {
        lhs - plusOrMinus(oneSided: true)
    }
    var upperConfidenceBound: R {
        lhs + plusOrMinus(oneSided: true)
    }
    var interval: (R, R) { (lhs - plusOrMinus, lhs + plusOrMinus) }
    
    var useTDist: Bool { // Implement in child classes
        fatalError()
    }
}

class DifferenceConfidenceIntervalForMeans: DifferenceConfidenceInterval {
    override var lhs: R { abs(self.sample.mean - self.sample2.mean) }
    
    override var item: String { "μₓ - μᵧ" } // (Use μ since this is an estimate for the population mean difference, not for the sample means with bars on it.)
    //override var item: String { "X̄ - Ȳ" }
    
    init(sample: SampleOrPopulation, minus sample2: SampleOrPopulation, level: R, bothAreSampleStdev: Bool = false) {
        self.sample = sample
        self.sample2 = sample2
        super.init()
        self.level = level
        self.sampleStdev = bothAreSampleStdev
    }
    
    var degreeOfFreedom: R {
        let temp1 = sample.variance / intToℝ(sample.nOrN)
        let temp2 = sample2.variance / intToℝ(sample2.nOrN)
        let temp3 = temp1 + temp2
        let degreeOfFreedom = floor((temp3 * temp3) / ((temp1 * temp1) / (intToℝ(sample.nOrN) - 1) + (temp2 * temp2) / (intToℝ(sample2.nOrN) - 1)))
        return degreeOfFreedom
    }
    
    override func plusOrMinus(oneSided: Bool = false) -> R {
        // Check for small sample
        var score: R!
        if useTDist {
            //precondition(sampleStdev)
            let degreeOfFreedom = self.degreeOfFreedom
            if degreeOfFreedom > 30 {
                print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Edge case")
                score = ConfidenceInterval.zscore(forLevel: level, oneSided: oneSided)
            }
            else {
                score = ConfidenceInterval.tDistribution(ν: ℝtoInt(degreeOfFreedom), α: (1 - level) / (oneSided ? 1 : 2))
            }
        }
        else {
            //precondition(!sampleStdev)
            score = ConfidenceInterval.zscore(forLevel: level, oneSided: oneSided)
        }
        
        return score * sqrt(sample.variance / intToℝ(sample.nOrN) + sample2.variance / intToℝ(sample2.nOrN))
    }
    
    var sampleStdev: Bool = false
    var sample: SampleOrPopulation
    var sample2: SampleOrPopulation
    var smallSample: Bool { sample.nOrN <= 30 && sample2.nOrN <= 30 }
    override var useTDist: Bool { smallSample }
}

// Uses Agresti-Coull modification.
class DifferenceConfidenceIntervalForProportions: DifferenceConfidenceInterval {
    override var lhs: R { abs(pTilde - p2Tilde) }

    override var item: String { "pₓ - pᵧ" }
    
    init(proportionNumerator: Int, n: Int, minus proportionNumerator2: Int, n2: Int, level: R) {
        self.proportionNumerator = proportionNumerator
        self.n = n
        self.proportionNumerator2 = proportionNumerator2
        self.n2 = n2
        super.init()
        self.level = level
    }
    
    override func plusOrMinus(oneSided: Bool = false) -> R {
        // Check for small sample
        var score: R!
        if useTDist {
            score = ConfidenceInterval.tDistribution(ν: n + n2 - 2 /*TODO: correct?*/, α: (1 - level) / (oneSided ? 1 : 2))
        }
        else {
            score = ConfidenceInterval.zscore(forLevel: level, oneSided: oneSided)
        }
        
        let res1 = pTilde * (1-pTilde) / intToℝ(nTilde)
        let res2 = p2Tilde * (1-p2Tilde) / intToℝ(n2Tilde)
        return score * sqrt(res1 + res2)
    }
    
    var proportionNumerator: Int
    var pTilde: R { (intToℝ(proportionNumerator) + 1) / intToℝ(nTilde) }
    var n: Int
    var nTilde: Int { n + 2 }
    var proportionNumerator2: Int
    var p2Tilde: R { (intToℝ(proportionNumerator2) + 1) / intToℝ(n2Tilde) }
    var n2: Int
    var n2Tilde: Int { n2 + 1 }
    override var useTDist: Bool { false }
}

class DifferenceConfidenceIntervalForPairedData: DifferenceConfidenceInterval {
    override var lhs: R { sample.mean }

    override var item: String { item_ }
    internal var item_: String
    
    // `item` can be `μ` to get the mean of the difference between each pair in `items`.
    init(items: [(R, R)], item: String, level: R) {
        // First, find out if more (>50%) of {the first item in the pair minus the second item} are positive, or not:
        var positive = 0
        for xAndY in items {
            if xAndY.0 > xAndY.1 {
                positive += 1
            }
        }
        self.firstMinusSecondIsGood = positive >= items.count / 2
        let firstMinusSecondIsGood = self.firstMinusSecondIsGood
        
        self.sample = Sample(items.reduce([], {(acc: [R], xAndY: (R, R)) -> [R] in
            return acc + [firstMinusSecondIsGood ? xAndY.0 - xAndY.1 : xAndY.1 - xAndY.0]
        }))
        self.item_ = item
        super.init()
        self.level = level
    }
    
    convenience init(items1: [R], items2: [R], item: String, level: R) {
        self.init(items: Array(zip(items1, items2)), item: item, level: level)
    }
    
    override func plusOrMinus(oneSided: Bool = false) -> R {
        if item_ == "μ" {
            // Check for small sample
            var score: R!
            if useTDist {
                score = ConfidenceInterval.tDistribution(ν: n - 1, α: (1 - level) / (oneSided ? 1 : 2))
            }
            else {
                score = ConfidenceInterval.zscore(forLevel: level, oneSided: oneSided)
            }
            
            return score * sample.stdev / sqrt(intToℝ(n))
        }
        else {
            fatalError("Unknown test")
        }
    }
    
    var sample: SampleOrPopulation
    var smallSample: Bool { n <= 30 }
    var n: Int { sample.nOrN }
    override var useTDist: Bool { smallSample }
    
    var firstMinusSecondIsGood: Bool
}
