//
//  H.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Hypergeometric distribution
class H: SampleOrPopulation, Distribution {
    // MARK: Distribution
    
    func p(XIsExactly x: Int) -> __0iTo1i {
        guard 0 <= x && x <= R &&
            0 <= n - x && n - x <= N - R else { return __0iTo1i(ℝ_0to1: 0) }
        return __0iTo1i(ℝ_0to1:
            bigIntToℝ(Combination(numberOfItemsToArrange: R).totalNumberOfChoices(takingOnly: x) * Combination(numberOfItemsToArrange: N - R).totalNumberOfChoices(takingOnly: n - x)) / bigIntToℝ(Combination(numberOfItemsToArrange: N).totalNumberOfChoices(takingOnly: n))
        )
    }
    
    func p(XIsGreaterThan x: Int) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    func p(XIsLessThan x: Int) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ { intToℝ(n * R) / intToℝ(N) }
    
    var variance: ℝ { intToℝ(n * R) / intToℝ(N) * (1 - intToℝ(R) / intToℝ(N)) * (intToℝ(N - n) / intToℝ(N - 1)) }
    
    var stdev: ℝ { sqrt(variance) }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Geom
    
    init(population N: Int, sucesses R: Int, sampleChosen n: Int) {
        self.N = N
        self.R = R
        self.n = n
    }
    
    var N: Int
    var R: Int
    var n: Int
}
