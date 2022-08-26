//
//  SampleOrPopulation.swift
//  ProbTh
//
//  Created by sbond75 on 8/24/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

protocol SampleOrPopulation {
    var nOrN: Int { get }
    var mean: ℝ { get }
    var variance: ℝ { get }
    // Standard deviation
    var stdev: ℝ { get }
    
    var sampleOrPopulation: [ℝ] { get }
}

class SampleOrPopulation_impl: SampleOrPopulation {
    var nOrN: Int { sampleOrPopulation.count }
    var mean: ℝ { sampleOrPopulation.reduce(0, {acc, x_i in acc + x_i}) / ℝ(nOrN) }
    var variance: ℝ { fatalError() }
    // Standard deviation
    var stdev: ℝ { sqrt(variance) }
    
    var sampleOrPopulation = [ℝ]() // aka "X"
    
    init(_ sampleOrPopulation: [ℝ]) {
        self.sampleOrPopulation = sampleOrPopulation
    }
    
    // Computes Ȳ = a + b * X̄ and returns Ȳ.
    static func mean(givenA a: ℝ, andB b: ℝ, andOtherMean X̄: SampleOrPopulation) -> ℝ {
        return a + b * X̄.mean
    }
    
    // Computes S_y^2 = b^2 * S_x^2 and returns S_y^2
    static func variance(givenA a: ℝ, andB b: ℝ, andOtherStdev S_x: SampleOrPopulation) -> ℝ {
        return pow(b, 2) * S_x.variance
    }
    
    // Computes S_y = |b| * S_x and returns S_x
    static func stdev(givenA a: ℝ, andB b: ℝ, andOtherStdev S_x: SampleOrPopulation) -> ℝ {
        return abs(b) * S_x.stdev
    }
    
    func pthPercentile(p: __0iTo1i) -> ℝ {
        var i: ℝ = p.ℝ_0to1 * ℝ(1 + nOrN)
        i -= 1 // Adjust for 0-based indexing
        if floor(i) == i {
            // i is a whole number
            return sorted[Int(i)]
        }
        else {
            // i is not a whole number
            return (sorted[Int(ceil(i))] + sorted[Int(floor(i))]) / 2
        }
    }
    
    // First quartile or 25th percentile
    var q1: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.25)) }
    // Second quartile or 50th percentile or median
    var q2: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.50)) }
    var median: ℝ { q2 }
    // Third quartile or 75th percentile
    var q3: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.75)) }
    
    private var _sorted: [ℝ]?
    var sorted: [ℝ] {
        get {
            if let _sorted = _sorted {
                return _sorted
            }
            else {
                let retval = sampleOrPopulation.sorted()
                _sorted = retval
                return retval
            }
        }
    }
    var range: ℝ? {
        if let last = sorted.last, let first = sorted.first {
            return last - first
        }
        return nil
    }
    
    var iqr: ℝ! { q3 - q1 }
    
    var modes: [ℝ] {
        return sampleOrPopulation.mostFrequent()?.mostFrequent ?? []
        
//        // Bad, not working: //
//        var indexSeen: Int? = sorted.count > 0 ? 0 : nil
//        var highestIndexSeen: Int? = indexSeen
//        var count: Int = 0
//        var highestCountSeen: Int = count
//        var i = 0
//        for e in sorted {
//            if e == sorted[indexSeen!] {
//                count += 1
//            }
//            else {
//                if highestIndexSeen == nil || indexSeen.unsafelyUnwrapped > highestIndexSeen.unsafelyUnwrapped {
//                    highestIndexSeen = indexSeen
//                }
//                if count > highestCountSeen {
//                    highestCountSeen = count
//                }
//                indexSeen = i
//                count = 1
//            }
//
//            i += 1
//        }
//
//        print(highestCountSeen)
//        if let highestIndexSeen = highestIndexSeen {
//            return sorted[highestIndexSeen]
//        }
//        else {
//            return nil
//        }
//        // //
    }
}

// https://stackoverflow.com/questions/48255497/calculation-mode-in-an-array-more-than-one-mode
extension Array where Element: Hashable {
    func mostFrequent() -> (mostFrequent: [Element], count: Int)? {
        var counts: [Element: Int] = [:]
            
        self.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        if let count = counts.max(by: {$0.value < $1.value})?.value {
            return (counts.compactMap { $0.value == count ? $0.key : nil }, count)
        }
        return nil
    }
}

// Fill in with given values
class SampleOrPopulation_givenValues: SampleOrPopulation {
    init(nOrN: Int, mean: ℝ, variance: ℝ, stdev: ℝ) {
        self.nOrN = nOrN
        self.mean = mean
        self.variance = variance
        self.stdev = stdev
    }
    
    var nOrN: Int
    var mean: ℝ
    var variance: ℝ
    var stdev: ℝ
    
    var sampleOrPopulation: [ℝ] { fatalError() }
}

class Population: SampleOrPopulation_impl {
    override var variance: ℝ { 1.0 / ℝ(nOrN) * sampleOrPopulation.reduce(0, {acc, x_i in
        acc + pow(x_i - mean, 2)
    }) }
}

class Sample: SampleOrPopulation_impl {
    override var variance: ℝ { 1.0 / ℝ(nOrN - 1) * sampleOrPopulation.reduce(0, {acc, x_i in
        acc + pow(x_i - mean, 2)
    }) }
}

func * (left: ℝ, right: SampleOrPopulation) -> SampleOrPopulation {
    return SampleOrPopulation_impl(right.sampleOrPopulation.map{$0 * left})
}

func + (left: ℝ, right: SampleOrPopulation) -> SampleOrPopulation {
    return SampleOrPopulation_impl(right.sampleOrPopulation.map{$0 + left})
}
