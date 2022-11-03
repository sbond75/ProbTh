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
    var μ_0: R
    var μStatus: Relation
    var isH0: Bool
    var isH1: Bool { !isH0 }
    
    var description: String { "\(isH0 ? "H₀" : "H₁"): μ \(μStatus) \(μ_0)" }
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
        assert(ht.μStatus == .equalTo && ht.isH0) // Otherwise, not yet implemented. (H1 shouldn't be too bad to check for -- invert all conditions maybe?)
        // TODO: assert ci is two-sided, else `alpha` below changes
        let alpha = 1 - ci.level
        
        if ht.μ_0 > ci.lhs - ci.plusOrMinus && ht.μ_0 < ci.lhs + ci.plusOrMinus {
            // μ_0 is within the CI
            return (.greaterThan, "P > \(alpha)") // P > alpha
        }
        if ht.μ_0 < ci.lhs + ci.plusOrMinus {
            // μ_0 is less than the CI
            return (.lessThan, "P < \(alpha)") // P < alpha
        }
        if ht.μ_0 > ci.lhs + ci.plusOrMinus {
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
        let testStatistic = (ci.X̄ - ht.μ_0) / (ci.sample.stdev / sqrt(intToℝ(ci.sample.nOrN)))
        
        switch ht.μStatus {
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
