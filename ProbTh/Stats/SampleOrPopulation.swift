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
    var stdev: ℝ { ℝ(sqrt(ℝtoDouble(variance))) }
    
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
    
    func pthPercentileAndIts1BasedIndex(p: __0iTo1i) -> (ℝ
        , (Int, Int) /* <--any of these integers are the p-th percentile's 1-based index if these integers are equal; otherwise, these integers are the 1-based indices of the two numbers that were "merged" to form the p-th percentile. */) {
        let i: Double = ℝtoDouble(p.ℝ_0to1 * ℝ(1 + nOrN))
        //i -= 1 // Adjust for 0-based indexing
        if floor(i) == i {
            // i is a whole number
            let iInt = Int(i)
            if iInt <= sorted.count { // This `if` check is needed for when `p == 1`. If so, the body of this if statement will not be executed.
                return (sorted.i(iInt)
                , (iInt, iInt))
            }
            return (sorted.last!, (sorted.count, sorted.count))
        }
        else {
            // i is not a whole number
            let ceiled = Int(ceil(i))
            let floored = Int(floor(i))
            if ceiled <= sorted.count {  // This `if` check is needed for when `p == 0.99`. If so, the body of this if statement will not be executed.
                return ((sorted.i(ceiled) + sorted.i(floored)) / 2
                , (ceiled, floored))
            }
            return (sorted.last!, (sorted.count, sorted.count))
        }
    }
    func pthPercentile(p: __0iTo1i) -> ℝ {
        return pthPercentileAndIts1BasedIndex(p: p).0
    }
    
    // First quartile or 25th percentile
    var q1: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.25)) }
    // Second quartile or 50th percentile or median
    var q2: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.50)) }
    var median: ℝ { q2 }
    // Third quartile or 75th percentile
    var q3: ℝ { pthPercentile(p: __0iTo1i(ℝ_0to1: 0.75)) }
    // All quartiles
    var quartiles: (ℝ, ℝ, ℝ) { (q1, q2, q3) }
    
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
    var max: ℝ? {
        if let last = sorted.last {
            return last
        }
        return nil
    }
    var min: ℝ? {
        if let first = sorted.first {
            return first
        }
        return nil
    }
    
    // For a histogram or stem-and-leaf plot, returns the stems and leaves: the array of pairs returned has a stem and all leaves for that stem in each element.
    // TODO: This assumes the stem is the ones place. In the future, make this setting a parameter maybe, or (better) infer it from `self.range` or something.
    var stemsAndLeaves: [(ℝ, [ℝ])] {
        let allStemsAndLeaves: [(ℝ, ℝ)] = sorted.map{$0.integerAndFractionParts}
//        allStemsAndLeaves.reduce(0, {acc,x in
//            acc + x.0
//        })
        
        var res = [(ℝ, [ℝ])]()
        var lastSeen: ℝ! = nil
        var currentLeaves = [R]()
        for x in allStemsAndLeaves {
            if lastSeen != nil {
                if lastSeen == x.0 {
                    // Within a "run" of the same stems
                    currentLeaves.append(x.1)
                }
                else {
                    // End of the "run"
                    res.append((lastSeen, currentLeaves))
                    currentLeaves = [R]()

                    lastSeen = x.0
                    currentLeaves.append(x.1)
                }
            }
            else {
                lastSeen = x.0
                currentLeaves.append(x.1)
            }
        }
        if lastSeen != nil {
            // End of the "run"
            res.append((lastSeen, currentLeaves))
        }
        
        return res
    }
    
    // IQR (Inter-quartile range)
    var iqr: ℝ { q3 - q1 }
    
    // For a boxplot, returns the "invisible lines" where the first element of the pair is based on Q_1 (the first quartile) and the second element is based on Q_3.
    var boxplotInvisibleLines: (ℝ, ℝ) { (q1 - 1.5 * iqr, q3 + 1.5 * iqr) }
    
    // "Whiskers" for the boxplot
    var minAndMaxWithinInvisibleLines: (ℝ, ℝ) { (sorted.filter{$0 > boxplotInvisibleLines.0}.first!, sorted.filter{$0 < boxplotInvisibleLines.1}.last!) }
    
    // For the boxplot. Values outside the `minAndMaxWithinInvisibleLines`.
    var extremeOutliers: [ℝ] { sorted.filter{$0 < minAndMaxWithinInvisibleLines.0 || $0 > minAndMaxWithinInvisibleLines.1} }
    
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

extension Array {
    // 1-based index accessor
    func i(_ index1Based: Int) -> Element { return self[index1Based - 1] }
}

// Fill in with given values
class SampleOrPopulation_givenValues: SampleOrPopulation {
    init(nOrN: Int?, mean: ℝ?, variance: ℝ?) {
        self.nOrN = nOrN ?? Int.min
        self.mean = mean ?? ℝ.nan
        self.variance = variance ?? ℝ.nan
    }
    
    init(nOrN: Int?, mean: ℝ?, stdev: ℝ) {
        self.nOrN = nOrN ?? Int.min
        self.mean = mean ?? ℝ.nan
        self.variance = pow(stdev, 2)
    }
    
    convenience init(stdev: ℝ) {
        self.init(nOrN: nil, mean: nil, stdev: stdev)
    }
    
    var nOrN: Int
    var mean: ℝ
    var variance: ℝ
    var stdev: ℝ { ℝ(sqrt(ℝtoDouble(variance))) }
    
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

// MARK: Operations on left-hand-side reals and `SampleOrPopulation`

func * (left: ℝ, right: SampleOrPopulation) -> SampleOrPopulation {
    return SampleOrPopulation_impl(right.sampleOrPopulation.map{$0 * left})
}

func + (left: ℝ, right: SampleOrPopulation) -> SampleOrPopulation {
    return SampleOrPopulation_impl(right.sampleOrPopulation.map{$0 + left})
}

func - (left: ℝ, right: SampleOrPopulation) -> SampleOrPopulation {
    return SampleOrPopulation_impl(right.sampleOrPopulation.map{$0 - left})
}

// MARK: Operations on left-hand-side reals and `SampleOrPopulation_givenValues`

// Note: It would be cool to somehow use this to build lazily evaluated multiplications, etc. as equations or something..
func * (left: ℝ, right: SampleOrPopulation_givenValues) -> SampleOrPopulation_givenValues {
    return SampleOrPopulation_givenValues(nOrN: right.nOrN, mean: right.mean * left, variance: right.variance * pow(left, 2))
}

func + (left: ℝ, right: SampleOrPopulation_givenValues) -> SampleOrPopulation_givenValues {
    return SampleOrPopulation_givenValues(nOrN: right.nOrN, mean: right.mean + left, variance: right.variance)
}

func - (left: ℝ, right: SampleOrPopulation_givenValues) -> SampleOrPopulation_givenValues {
    return SampleOrPopulation_givenValues(nOrN: right.nOrN, mean: left - right.mean, variance: right.variance)
}

// MARK: Operations on `SampleOrPopulation_givenValues`

func + (left: SampleOrPopulation_givenValues, right: SampleOrPopulation_givenValues) -> SampleOrPopulation_givenValues {
    return SampleOrPopulation_givenValues(nOrN: left.nOrN != Int.min && right.nOrN != Int.min ? (left.nOrN + right.nOrN) : Int.min // (This check prevents `Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)` which happens for some odd reason when adding -9223372036854775808 with -9223372036854775808)
        , mean: left.mean + right.mean, variance: left.variance + right.variance)
}
