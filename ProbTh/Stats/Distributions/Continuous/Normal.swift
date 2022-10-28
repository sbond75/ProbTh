//
//  Normal.swift
//  ProbTh
//
//  Created by sbond75 on 10/6/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class Normal: SampleOrPopulation, Distribution {
    // MARK: SampleOrPopulation
    
    var nOrN: Int { fatalError() }
    
    var mean: ℝ
    
    var variance: ℝ {
        get {
            stdev * stdev
        }
        set {
            stdev = sqrt(newValue)
        }
    }
    
    var stdev: ℝ
    
    var sampleOrPopulation: [ℝ] { fatalError() }
    
    // MARK: Distribution
    
    func p(XIsExactly x: R) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    func p(XIsGreaterThan x: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: 1 - p(XIsLessThan: x).ℝ_0to1)
    }
    
    func p(XIsLessThan x: R) -> __0iTo1i {
        let z = xToZ(x)
        return p(ZIsLessThan: z)
    }
    
    func p(givenValueIsLessThanX given: R, andXIsLessThan x: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: p(XIsLessThan: x).ℝ_0to1 - p(XIsLessThan: given).ℝ_0to1)
    }
    
    // MARK: Normal
    
    func p(XIsGreaterThanOrEqualTo x: R) -> __0iTo1i {
        return p(XIsGreaterThan: x)
    }
    
    func p(XIsLessThanOrEqualTo x: R) -> __0iTo1i {
        return p(XIsLessThan: x)
    }
    
    func p(ZIsExactly z: R) -> __0iTo1i {
        // Not yet implemented
        fatalError()
    }
    
    func p(ZIsGreaterThan z: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: 1 - p(ZIsLessThan: z).ℝ_0to1)
    }
    
    func p(ZIsLessThan z: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: doubleToℝ(Normal.percentile(zscore: ℝtoDouble(z))))
    }
    
    // Gives the X value at the percentile.
    func pthPercentile(p: __0iTo1i) -> R {
        return zToX(doubleToℝ(Normal.zscore(for: ℝtoDouble(p.ℝ_0to1))))
    }
    
    // Gives the percentile of the given X value.
    func percentile(of x: R) -> __0iTo1i {
        return __0iTo1i(ℝ_0to1: doubleToℝ(Normal.percentile(zscore: ℝtoDouble(xToZ(x)))))
    }
    
    // Uses the central limit theorem on X̄ to say that X̄ has the normal distribution with mean µ and variance (σ^2)/n.
    // NOTE: The Normal object you call the below method on should have a variance of simply σ^2, since this method finds the `n` in `(σ^2)/n` of `self`.
    func n(suchThatProbabilityIs p: R, thatTheSampleMeanIsLessThan x: R) -> R {
        let temp = (stdev * doubleToℝ(Normal.zscore(for: ℝtoDouble(p)))) / (x - mean)
        return temp * temp
    }
    
    init(mean: R, stdev: R) {
        self.mean = mean
        self.stdev = stdev
    }
    
    init(mean: R, variance: R) {
        self.mean = mean
        //self.variance = variance
        self.stdev = sqrt(variance)
    }
    
    // The standard normal distribution (mean = 0, stdev = 1)
    static var standard: Normal { Normal(mean: 0, stdev: 1) }
    
    func xToZ(_ x: R) -> R {
        return (x - mean) / stdev
    }
    
    func zToX(_ z: R) -> R {
        return z * stdev + mean
    }
    
    // https://stackoverflow.com/questions/36586214/z-score-to-percentile-conversion-in-swift
//    static func percentile (zscore z: Double) -> Int {
//        let tmp = 0.5 * (1 + erf(z / sqrt(2.0)))
//        return Int(round(tmp * 100))
//    }
    static func percentile (zscore z: Double) -> Double {
        let tmp = 0.5 * (1 + erf(z / sqrt(2.0)))
        return tmp
    }
    private static func equalByEpsilon(_ a: Double, _ b: Double, epsilon: Double) -> Bool {
        return abs(a - b) < epsilon
    }
    static func zscore (for percentile: Double) -> Double {
        // Brute-force hack:
        let accuracy = 15.0
        let epsilon = 0.0002
        var current: Double = -3.40
        // TODO: minor: Sam: use binary search instead of this ("bisection") for O(logn) instead of O(n) where n is 1/accuracy maybe
        while current <= 3.49 {
            let p = Normal.percentile(zscore: current)
            //print(p, current)
            if equalByEpsilon(p, percentile, epsilon: epsilon) {
                // Found it
                return current
            }
            current += 0.01 / 5.0 / accuracy
        }
        fatalError("potentially an error, check if `current <= 3.5` should be used instead of `current <= 3.49` in the while loop condition above")
        return current
    }
    // Notation type of thing. This gives the zscore with area alpha to its right.
    static func Z(alpha: Double) -> Double {
        let retval = zscore(for: 1 - alpha)
        let funFact = -zscore(for: alpha)
        assert(equalByEpsilon(retval, funFact, epsilon: 0.0105 /*0.0015*/), "Expected \(retval) to be nearly equal to \(funFact)") // Fun fact: these are equal. (Due to Swift implementation not using the z-table on http://www.z-table.com/ we have to have some epsilon for comparing here.)
        return retval
    }
    
}
