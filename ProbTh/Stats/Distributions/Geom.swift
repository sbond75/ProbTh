//
//  Geom.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Geometric distribution
class Geom: SampleOrPopulation, Distribution {
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ { 1 / p }
    
    var variance: ℝ { (1 - p) / (p * p) }
    
    var stdev: ℝ { doubleToℝ(sqrt(ℝtoDouble(variance))) }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Geom
    
    init(p: R) {
        self.p = p
    }
    
    // Probability that the `x`th trial is a success.
    func p(xthTrialIsSuccess x: Int) -> __0iTo1i {
        if x <= 0 {
            return __0iTo1i(ℝ_0to1: 0)
        }
        return __0iTo1i(ℝ_0to1:
            p * pow(1 - p, x - 1)
        )
    }
    
    // Synonym for the above.
    func p(XIsExactly x: Int) -> __0iTo1i {
        return p(xthTrialIsSuccess: x)
    }
    
    // Probability that the `n`th trial is a success where `n` > a given x. (Also known as the probability that X > x where X is the random variable described by this Geom distribution and `x` is the parameter to this function.)
    func p(XIsGreaterThan x: Int) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: 1 -
            (1...x).reduce(0, {acc,x in
                acc + p(xthTrialIsSuccess: x).ℝ_0to1
            })
        )
    }
    
    func p(XIsLessThan x: Int) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1:
            (1...x).reduce(0, {acc,x in
                acc + p(xthTrialIsSuccess: x).ℝ_0to1
            })
        )
    }
    
    var p: R
}
