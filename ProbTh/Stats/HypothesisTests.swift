//
//  HypothesisTests.swift
//  ProbTh
//
//  Created by sbond75 on 11/1/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

enum Relation: CustomStringConvertible {
    case lessThan
    case equalTo
    case greaterThan
    
    case lessThanOrEqualTo
    case notEqualTo
    case greaterThanOrEqualTo
    
    var description: String {
        switch self {
        case .lessThan:
            return "<"
        case .equalTo:
            return "="
        case .greaterThan:
            return ">"
        case .lessThanOrEqualTo:
            return "≤"
        case .notEqualTo:
            return "≠"
        case .greaterThanOrEqualTo:
            return "≥"
        }
    }
}

struct HypothesisTest: CustomStringConvertible {
    var lhs_0: R
    var lhsStatus: Relation
    var isH0: Bool
    var isH1: Bool { !isH0 }
    var lhs: String // Something like "μ". The left-hand side (lhs) of the HypothesisTest.
    var rhs: String? // If set, this is is of the form (assuming null hypothesis, i.e. it is H₀ and not H₁): H₀: lhs - rhs lhsStatus lhs_0
    
    var description: String {
        if let rhs = rhs {
            return "\(isH0 ? "H₀" : "H₁"): \(lhs) - \(rhs) \(lhsStatus) \(lhs_0)"
        }
        else {
            return "\(isH0 ? "H₀" : "H₁"): \(lhs) \(lhsStatus) \(lhs_0)"
        }
    }
    
    var isNullHypothesis: Bool { isH0 }
    var isAlternateHypothesis: Bool { isH1 }
    
    func pvalue(Z testStatistic: R) -> PValue {
        assert(isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
        
        switch lhsStatus {
        case .lessThanOrEqualTo:
            return PValue(pvalue: __0iTo1i(ℝ_0to1: doubleToℝ(
                Normal.percentile(zscore: ℝtoDouble(-testStatistic))
            )), twoSided: false)
        case .equalTo:
            return PValue(pvalue: __0iTo1i(ℝ_0to1: doubleToℝ(
                2 * Normal.percentile(zscore: -abs(ℝtoDouble(testStatistic)))
            )), twoSided: true)
        case .greaterThanOrEqualTo:
            return PValue(pvalue: __0iTo1i(ℝ_0to1: doubleToℝ(
                Normal.percentile(zscore: ℝtoDouble(testStatistic))
            )), twoSided: false)
        default:
            fatalError("Not yet implemented")
        }
    }
}

struct PValue {
    var pvalue: __0iTo1i
    
    func isH0RejectedAt(level: __0iTo1i) -> Bool {
        return level.ℝ_0to1 > pvalue.ℝ_0to1
    }
    func isH1AcceptedAt(level: __0iTo1i) -> Bool {
        return !isH0RejectedAt(level: level)
    }
    
    var twoSided: Bool? = nil // nil if unspecified
    
    var oneSided: Bool {
        guard let twoSided = twoSided else { return true } // Assume one-sided
        return !twoSided
    }
    
    var twoSidedPValue: __0iTo1i {
        return __0iTo1i(ℝ_0to1: oneSided ? 2 * pvalue.ℝ_0to1 : pvalue.ℝ_0to1)
    }
    
    static func pvalueRelationToAlpha(of ht: HypothesisTest, given confidenceInterval: CI) -> (Relation, String /* description */) {
        let ci = confidenceInterval
        assert(ci.item == "μ")
        assert(ht.lhsStatus == .equalTo && ht.isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
        // TODO: assert ci is two-sided, else `alpha` below changes
        let alpha = 1 - ci.level
        
        if ht.lhs_0 > ci.lhs - ci.plusOrMinus && ht.lhs_0 < ci.lhs + ci.plusOrMinus {
            // μ_0 is within the CI
            return (.greaterThan, "P > \(alpha)") // P > alpha
        }
        if ht.lhs_0 < ci.lhs + ci.plusOrMinus {
            // μ_0 is less than the CI
            return (.lessThan, "P < \(alpha)") // P < alpha
        }
        if ht.lhs_0 > ci.lhs + ci.plusOrMinus {
            // μ_0 is less than the CI
            return (.lessThan, "P < \(alpha)") // P < alpha
        }
        fatalError()
    }
    
    static func pvalue(of ht: HypothesisTest,
                       given confidenceInterval: ConfidenceInterval /* NOTE: `level:` can be left 0 for no level.. */) -> PValue {
        let ci = confidenceInterval
        assert(ci.item == "μ")
        assert(ht.isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
        
        // "Z"
        let testStatistic = (ci.X̄ - ht.lhs_0) / (ci.sample.stdev / sqrt(intToℝ(ci.sample.nOrN)))
        
        return ht.pvalue(Z: testStatistic)
    }
    
    static func pvalue(of ht: HypothesisTest,
                       given bin: Bin) -> PValue {
        assert(ht.isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
        let phat = bin.p
        let p0 = ht.lhs_0
        
        // "Z"
        let testStatistic = (phat - p0) / sqrt(p0 * (1 - p0) / intToℝ(bin.n))
        
        return ht.pvalue(Z: testStatistic)
    }
    
//    static func pvalue(of ht: HypothesisTest,
//                       given X: Bin, XNumerator /*numerator of success rate p of X~Bin*/: Int,
//                       and Y: Bin, YNumerator /*numerator of success rate p of Y~Bin*/: Int) -> PValue {
//        precondition(ht.rhs != nil && ht.lhs.starts(with: "p") && ht.rhs!.starts(with: "p"), "Needs to be a difference between proportions")
//        assert(ht.isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
//        let phatX = X.p
//        let phatY = Y.p
//        
//        // Compute the "pooled proportion"
//        let phat = intToℝ(XNumerator + YNumerator) / intToℝ(X.n + Y.n)
//        
//        // "Z"
//        let testStatistic = intToℝ(phatX - phatY) / sqrt(phat * (1-phat) * (1/intToℝ(X.n) + 1/intToℝ(X.y)))
//        
//        return ht.pvalue(Z: testStatistic)
//    }
}
