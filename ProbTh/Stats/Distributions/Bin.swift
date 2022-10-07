//
//  Bin.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Binomial distribution
class Bin: MultinomialDist {
    // MARK: Distribution
    
    override func p(XIsExactly x: Int) -> __0iTo1i {
        guard x > 0 && x <= n else { return __0iTo1i(ℝ_0to1: 0) }
        return p(groupSizesAreExactly: [x, n - x])
    }
    
    override func p(XIsGreaterThan x: Int) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    override func p(XIsLessThan x: Int) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    // MARK: SampleOrPopulation
    
    override var nOrN: Int { fatalError() }
    
    override var mean: ℝ { intToℝ(n) * p }
    
    override var variance: ℝ { intToℝ(n) * p * (1 - p) }
    
    override var stdev: ℝ { sqrt(variance) }
    
    override var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Bin
    
    init(numberOfTrials n: Int, successRate p: R) {
        super.init(numberOfItemsToArrange: n, probabilitiesOfEachOutcome: [p, 1 - p])
    }
    
    var p: R { p_i[0] }
}
