//
//  ChiSquaredTests.swift
//  ProbTh
//
//  Created by sbond75 on 11/10/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import SwiftyStats

// 2-dimensional independence test or 1-dimensional goodness-of-fit test (6.10 notes)
class IndependenceTest {
    // `observed` can be just a column vector (1D) or have more than one column (2D).
    // `expectedPercentages` is implemented for 1D only currently.
    init(observed: Matrix, expectedPercentages: [__0iTo1i]? = nil) {
        self.observed = observed
        let sum = self.observed.sum()
        self.expectedPercentages = expectedPercentages ?? (is1D ? Array<__0iTo1i>(repeating: __0iTo1i(ℝ_0to1: doubleToℝ(sum / Double(self.observed.count) / sum)), count: self.observed.count) : nil)
    }
    
    var pvalue: PValue {
        do {
            return PValue(pvalue: __0iTo1i(ℝ_0to1: doubleToℝ(try 1 - SSProbDist.ChiSquare.cdf(chi: ℝtoDouble(testStatistic), degreesOfFreedom: Double(degreeOfFreedom))))) // TODO: why "1 -" is needed here but not on my paper chi-squared table?
        }
        catch let error {
            print("IndependenceTest.pvalue: error: \(error)")
            fatalError()
        }
    }
    
    // The chi-squared value.
    var testStatistic: R {
        let temp = observed - expected
        return doubleToℝ((temp * temp / expected).sum())
    }
    
    // The expected values table.
    var expected: Matrix {
        let total = observed.sum()
        
        if let expectedPercentages = expectedPercentages {
            return Matrix([expectedPercentages.map{ℝtoDouble($0.ℝ_0to1)}]) * total
        }
        
        // Compute sums divided by total per row and then per column
        let rowSumsDividedByTotal = observed.sumRows() / total
        let columnSumsDividedByTotal = observed.sumColumns() / total
        // Compute the expected table
        var expected = Matrix(rows: rowSumsDividedByTotal.count, columns: columnSumsDividedByTotal.count, repeatedValue: 0)
        var rowIndex = 0, colIndex = 0;
        for row in rowSumsDividedByTotal.grid {
            for col in columnSumsDividedByTotal.grid {
                expected[rowIndex, colIndex] = total * row * col
                colIndex += 1
            }
            colIndex = 0
            rowIndex += 1
        }
        return expected
    }
    
    var degreeOfFreedom: Int {
        return ((observed.rows - 1) <= 0 ? 1 : (observed.rows - 1)) * (observed.columns - 1)
    }
    
    var is1D: Bool {
        return !is2D
    }
    var is2D: Bool {
        return observed.rows > 1 && observed.columns > 1
    }
    
    var observed: Matrix
    var expectedPercentages: [__0iTo1i]?
}
