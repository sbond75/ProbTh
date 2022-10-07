//
//  Multinomial.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Multinomial distribution
class MultinomialDist: SampleOrPopulation, Distribution {
    // This takes in a list of x_1 through x_k where k is the number of outcomes and each x_i is the number of each outcome for which you are asking the probability.
    func p(groupSizesAreExactly x_i: [Int]) -> __0iTo1i {
        guard x_i.reduce(0, +) == n && x_i.reduce(false, {$0 || 0 <= $1 && $1 <= n}) else { return __0iTo1i(ℝ_0to1: 0) }
        return __0iTo1i(ℝ_0to1:
            bigIntToℝ(Multinomial(numberOfItemsToArrange: n, groupSizes: x_i).totalNumberOfChoices) * zip(p_i, x_i).reduce(1, {acc,pAndX_i in
                let p_i = pAndX_i.0
                let x_i = pAndX_i.1
                return acc * pow(p_i, x_i)
            })
        )
    }
    
    // MARK: Distribution
    
    // Not implemented since it doesn't exist for this distribution basically...
    func p(XIsExactly x: Int) -> __0iTo1i {
        fatalError()
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
    
    var mean: ℝ { // Not yet implemented
        fatalError()
    }
    
    var variance: ℝ { // Not yet implemented
        fatalError()
    }
    
    var stdev: ℝ { // Not yet implemented
        fatalError()
    }
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: MultinomialDist
    
    init(numberOfItemsToArrange n: Int, probabilitiesOfEachOutcome p_i: [R]) {
        let _ = __0iTo1i(ℝ_0to1: p_i.reduce(0, +)) // Ensure __0iTo1i property is held.
        
        self.n = n
        self.p_i = p_i
    }
    
    var n: Int
    var p_i: [R]
}
