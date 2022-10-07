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
    
    init(mean: R, stdev: R) {
        self.mean = mean
        self.stdev = stdev
    }
    
    init(mean: R, variance: R) {
        self.mean = mean
        //self.variance = variance
        self.stdev = sqrt(variance)
    }
    
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
    static func zscore (for percentile: Double) -> Double {
        // Brute-force hack:
        let accuracy = 15.0
        let epsilon = 0.0002
        var current: Double = -3.40
        while current <= 3.49 {
            let p = Normal.percentile(zscore: current)
            //print(p, current)
            if abs(p - percentile) < epsilon {
                // Found it
                return current
            }
            current += 0.01 / 5.0 / accuracy
        }
        return current
    }
    
}
