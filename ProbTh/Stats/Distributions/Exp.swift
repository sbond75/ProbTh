//
//  Exp.swift
//  ProbTh
//
//  Created by sbond75 on 10/4/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// The exponential distribution
class Exp: Poisson {
    // MARK: Distribution
    // NOTE: this uses Poisson's functions since X, a Poisson random variable, is kind of "decorated" by this class which has a new random variable: T.
    
    // MARK: SampleOrPopulation
    
    // Mean waiting time between occurrences of the Poisson process described by this exponential distribution.
    override var mean: ℝ { 1 / rate }
    
    override var variance: ℝ { 1 / (rate * rate) }
    
    override var stdev: ℝ { 1 / rate }
    
    // MARK: Exp
    
    init(from poisson: Poisson) {
        super.init(rate: poisson.rate)
        self.timeUnitFromEstimation = poisson.timeUnitFromEstimation
    }
    // NOTE: this shouldn't be an override...?:
    override init(rate: R) {
        super.init(rate: rate)
    }
    
    init(estimatingFromWaitingTimesForEachOccurrence waitingTimes: [R]) {
        let timeUnit = (waitingTimes.reduce(0, {acc,x in
            acc + x
        }) / intToℝ(waitingTimes.count))
        super.init(rate: 1 / timeUnit)
        self.timeUnitFromEstimation = timeUnit // Units: the time unit
        self.numWaitingTimesFromEstimation = waitingTimes.count
    }
    var numWaitingTimesFromEstimation: Int? = nil
    // σ_{lambda hat}
    override var uncertaintyInTheEstimate: R! { 1 / (timeUnitFromEstimation! * doubleToℝ(sqrt(Double(numWaitingTimesFromEstimation!)))) }
    // μ_{lambda hat}
    // Units: occurrences per time unit
    override var meanOfLambdaHat: R { (intToℝ(numWaitingTimesFromEstimation! + 1) / intToℝ(numWaitingTimesFromEstimation!)) * rate }
    // "Bias-corrected" μ_{lambda hat}
    // Units: occurrences per time unit
    var biasCorrectedEstimateForMeanOfLambdaHat: R {
        let n = numWaitingTimesFromEstimation!
        return 1 / timeUnitFromEstimation! * (intToℝ(n) / intToℝ(n + 1))
    }
    // "Bias-corrected" lambda hat
    // Units: occurrences per time unit
    var biasCorrectedEstimateForLambdaHat: R { biasCorrectedEstimateForMeanOfLambdaHat }
    
    // Probability that T < t, where T is the random variable described by this distribution.
    func p(TIsLessThan t: R) -> __0iTo1i {
        if t < 0 {
            return __0iTo1i(ℝ_0to1: 0)
        }
        return __0iTo1i(ℝ_0to1: 1 - doubleToℝ(exp(ℝtoDouble(-rate * t))))
    }
    
    // Probability that T > t, where T is the random variable described by this distribution.
    func p(TIsGreaterThan t: R) -> __0iTo1i {
        if t < 0 {
            return __0iTo1i(ℝ_0to1: 1)
        }
        return __0iTo1i(ℝ_0to1: doubleToℝ(exp(ℝtoDouble(-rate * t))))
    }
    
    func pthPercentile(p: __0iTo1i) -> ℝ {
        return doubleToℝ(log(ℝtoDouble(1 - p.ℝ_0to1))) / -rate
    }
}
