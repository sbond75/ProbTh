//
//  Uniform.swift
//  ProbTh
//
//  Created by sbond75 on 10/6/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class U: SampleOrPopulation, Distribution {
    // MARK: Distribution
    
    typealias T = R
    
    func p(XIsExactly x: R) -> __0iTo1i {
        __0iTo1i(ℝ_0to1: (a < x && x < b) ? (1 / (b - a)) : 0)
    }
    
    func p(XIsGreaterThan x: R) -> __0iTo1i {
        if x < a {
            return __0iTo1i(ℝ_0to1: 1 - 0) // TODO: correct?
        }
        if x > b {
            return __0iTo1i(ℝ_0to1: 1 - 1) // TODO: correct?
        }
        // Get portion of rectangle area within x to b.
        return __0iTo1i(ℝ_0to1: (b - x) / (b - a))
    }
    
    func p(XIsLessThan x: R) -> __0iTo1i {
        if x < a {
            return __0iTo1i(ℝ_0to1: 0)
        }
        if x > b {
            return __0iTo1i(ℝ_0to1: 1)
        }
        // Get portion of rectangle area within a to x.
        return __0iTo1i(ℝ_0to1: (x - a) / (b - a))
    }
    
    func p(givenValueIsLessThanX given: R, andXIsLessThan x: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: p(XIsLessThan: x).ℝ_0to1 - p(XIsLessThan: given).ℝ_0to1)
    }
    
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ { (a + b) / 2 }
    
    var variance: ℝ { ((b - a) * (b - a)) / 12 }
    
    var stdev: ℝ { sqrt(variance) }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Uniform
    
    // Init with an interval a to b.
    init(a: R, b: R) {
        self.a = a
        self.b = b
    }

    var a: R
    var b: R
}
