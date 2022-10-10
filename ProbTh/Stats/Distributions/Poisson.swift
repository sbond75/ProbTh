//
//  Poisson.swift
//  ProbTh
//
//  Created by sbond75 on 9/25/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import Accelerate
import BigInt

class Poisson: SampleOrPopulation, Distribution {
    // MARK: Distribution
    // NOTE: these are more limited versions of "in the next" `t` time units functions available in this Poisson class.
    
    func p(XIsExactly x: Int) -> __0iTo1i {
        p(x: x)
    }
    
    func p(XIsGreaterThan x: Int) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: 1 - p(XIsLessThan: x).ℝ_0to1) // TODO: untested
    }
    
    func p(XIsLessThan x: Int) -> __0iTo1i {
        p(XIsLessThan: x, inNext: 1.0)
    }
    
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ { rate }
    
    var variance: ℝ { rate }
    
    var stdev: ℝ { doubleToℝ(sqrt(ℝtoDouble(variance))) }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Poisson
    
    init(items: R, per timeUnit: R) {
        self.rate = items / timeUnit
    }
    
    init(rate: R) {
        self.rate = rate
    }
    
    init(estimatingFrom nItemsAndTimesList: [(Int, R)]) {
        self.rate = nItemsAndTimesList.reduce(0, {acc,x in
            acc + intToℝ(x.0) / x.1
        })
        self.timeUnitFromEstimation = nItemsAndTimesList.reduce(0, {acc,x in acc + x.1}) // Sum up the times list instead of taking the average because Sam: if you observe for 5 seconds now, then 2 seconds later, then it should be the same as if you observed for 7 seconds now.
    }
    var timeUnitFromEstimation: R? = nil
    var isEstimatedLambda: Bool { timeUnitFromEstimation != nil }
    init(estimatingFrom nItemsList: [Int], per timeUnit: R) {
        self.rate = nItemsList.reduce(0, {acc,x in
            acc + intToℝ(x) / timeUnit
        })
        self.timeUnitFromEstimation = timeUnit
    }
    // σ_{lambda hat}
    var uncertaintyInTheEstimate: R! { doubleToℝ(sqrt(ℝtoDouble(rate / timeUnitFromEstimation!))) }
    // μ_{lambda hat}
    var meanOfLambdaHat: R { rate }
    
    func prob(nItems: Int, inNext timeUnits: R) -> __0iTo1i {
        return p(x: nItems, inNext: timeUnits)
    }
    
    func p(x: Int, inNext t: R = 1.0) -> __0iTo1i {
        let lambdaPrime = rate * t
        return __0iTo1i(ℝ_0to1: doubleToℝ(exp(ℝtoDouble(-lambdaPrime)) * pow(ℝtoDouble(lambdaPrime), Double(x)) / Double(factorial(x)))) // TODO: more precision than Double when converting factorial
    }
    
    func p(XIsLessThan x: Int, inNext t: R = 1.0) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: (0..<x).reduce(intToℝ(0), {acc,x in
            acc + self.p(x: x, inNext: t).ℝ_0to1
        }))
    }
    
    var rate: R
}
