//
//  LeastSquaresLine.swift
//  ProbTh
//
//  Created by sbond75 on 11/27/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class LeastSquaresLine {
    init(X: Sample, Y: Sample) {
        assert(X.nOrN == Y.nOrN)
        self.X = X
        self.Y = Y
    }
    
    convenience init(X: [R], Y: [R]) {
        self.init(X: Sample(X), Y: Sample(Y))
    }

    convenience init(_ xAndY: [(R, R)]) {
        self.init(X: Sample(xAndY.map{$0.0}), Y: Sample(xAndY.map{$0.1}))
    }
    
    // Init with known stdev for X and Y, along with the sample correlation coefficient between X and Y.
    convenience init(stdevX: R, stdevY: R, r_X_Y: R) {
        self.init(X: SampleOrPopulation_givenValues(stdev: stdevX), Y: SampleOrPopulation_givenValues(stdev: stdevY), r_X_Y: r_X_Y)
    }
    // Init with known stdev for X and Y, along with the sample correlation coefficient between X and Y.
    init(X: SampleOrPopulation_givenValues, Y: SampleOrPopulation_givenValues, r_X_Y: R) {
        self.X = Sample([]) // Unused
        self.Y = Sample([]) // Unused
        
        self._X = X
        self._Y = Y
        self._r_X_Y = r_X_Y
    }
    
    var beta1Hat: R {
        if wasMadeGivenStdev {
            return r_X_Y * _Y!.stdev / _X!.stdev
        }
        
        let s1 = X
        let s2 = Y
        let sum1 = (1...s1.nOrN).reduce(0, {acc,i in acc + s1.sampleOrPopulation.i(i) * s2.sampleOrPopulation.i(i)})
        let sum2 = (1...s1.nOrN).reduce(0, {acc,i in acc + s1.sampleOrPopulation.i(i) * s1.sampleOrPopulation.i(i)})
        return (sum1 - intToℝ(X.nOrN) * s1.mean * s2.mean) / (sum2 - intToℝ(X.nOrN) * s1.mean * s1.mean)
    }
    
    var beta0Hat: R {
        Y.mean - beta1Hat * X.mean
    }
    
    // y_i hat
    func fittedValue(i indexOneBased: Int) -> R {
        return beta0Hat + beta1Hat * X.sampleOrPopulation.i(indexOneBased)
    }
    
    // e_i
    func residual(i indexOneBased: Int) -> R {
        return Y.sampleOrPopulation.i(indexOneBased) - fittedValue(i: indexOneBased)
    }
    
    // Also known as ESS or SSE
    var errorSumOfSquares: R {
        (1...Y.nOrN).reduce(0, {acc,i in acc + residual(i: i) * residual(i: i)})
    }
    
    // Also known as TSS or SST
    var totalSumOfSquares: R {
        (1...Y.nOrN).reduce(0, {acc,i in
            let temp = Y.sampleOrPopulation.i(i) - Y.mean
            return acc + temp * temp
        })
    }
    
    // Also known as the "coefficient of determination"
    var RSquared: R {
        let temp = r_X_Y
        let res = temp * temp
//        print(res)
//        print((totalSumOfSquares - errorSumOfSquares) / totalSumOfSquares)
        assert(equalByEpsilon((totalSumOfSquares - errorSumOfSquares) / totalSumOfSquares, res, epsilon: 0.000000000000001)) // fun fact (a bit off due to strange float rounding error)
        return res
    }
    
    var r_X_Y: R {
        if wasMadeGivenStdev {
            return _r_X_Y!
        }
        return correlation(X, Y)
    }
    
    var X: Sample
    var Y: Sample
    
    var wasMadeGivenStdev: Bool { _X != nil }
    internal var _X: SampleOrPopulation_givenValues?
    internal var _Y: SampleOrPopulation_givenValues?
    internal var _r_X_Y: R?
}
