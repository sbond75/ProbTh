//
//  Weibull.swift
//  ProbTh
//
//  Created by sbond75 on 10/6/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class Weibull: SampleOrPopulation, Distribution {
    // MARK: Distribution
    
    typealias T = R
    
    // PDF aka F(x), integral of f(x)
    func p(XIsExactly x: R) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: x > 0 ? alpha * pow(beta, alpha) * pow(x, alpha - 1) * exp(-pow(beta * x, alpha)) : 0)
    }
    
    func p(XIsGreaterThan x: R) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: 1 - p(XIsLessThan: x).ℝ_0to1)
    }
    
    func p(XIsLessThan x: R) -> __0iTo1i {
        p(XIsLessThanOrEqualTo: x)
    }
    
    // CDF aka f(x), derivative of F(x)
    func p(XIsLessThanOrEqualTo x: R) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: x > 0 ? 1 - exp(-pow(beta * x, alpha)) : 0)
    }
    
    func p(givenValueIsLessThanX given: R, andXIsLessThan x: R) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: p(XIsLessThanOrEqualTo: x).ℝ_0to1 - p(XIsLessThanOrEqualTo: given).ℝ_0to1)
    }
    
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ { // Not yet implemented
    fatalError() }
    
    var variance: ℝ { // Not yet implemented
    fatalError() }
    
    var stdev: ℝ { sqrt(variance) }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Weibull
    
    init(alpha: R, beta: R) {
        self.alpha = alpha
        self.beta = beta
    }
    
    var shape: R { alpha }
    var scale: R { 1 / beta }

    var alpha: R
    var beta: R
}
