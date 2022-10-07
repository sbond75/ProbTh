//
//  NB.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Negative binomial distribution
class NB: Geom {
    // MARK: SampleOrPopulation
    
    override var mean: ℝ { intToℝ(r) / p }
    
    override var variance: ℝ { intToℝ(r) * (1 - p) / (p * p) }
    
    override var stdev: ℝ { doubleToℝ(sqrt(ℝtoDouble(variance))) }
    
    // MARK: NB
    
    init(from geom: Geom, withIndependentCopies r: Int) {
        self.r = r
        super.init(p: geom.p)
    }
    
    override func p(xthTrialIsSuccess x: Int) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1:
            bigIntToℝ(Combination(numberOfItemsToArrange: x - 1).totalNumberOfChoices(takingOnly: r - 1)) * pow(p, r) * pow(1 - p, x - r)
        )
    }
    
    override func p(XIsGreaterThan x: Int) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: 1 -
            (r..<x).reduce(0, {acc,x in // TODO: correct impl?
                acc + p(xthTrialIsSuccess: x).ℝ_0to1
            })
        )
    }
    
    override func p(XIsLessThan x: Int) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1:
            (r..<x).reduce(0, {acc,x in
                acc + p(xthTrialIsSuccess: x).ℝ_0to1
            })
        )
    }
    
    // "r independent copies of Geom(p)"
    var r: Int
}
