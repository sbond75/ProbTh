//
//  JointDiscreteRandomVariables.swift
//  ProbTh
//
//  Created by sbond75 on 9/11/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// Joint probability mass function (PMF)
class JointPMF {
    // `data` is organized so that each array within the array is a row of values with changing X values. If you are providing xIndices and yIndices that are "flipped" then be sure to set the `transpose` argument to true. (Note: `transpose` does *not* transpose xIndices and yIndices, unlike the `.transposed` computed property in this class)
    // If nil, `xIndices` and `yIndices` are assumed to be 0 to `data`'s width or height, respectively.
    init(data: [[Double]], xIndices: [Int]? = nil, yIndices: [Int]? = nil, transpose: Bool = false) {
        contents = Matrix(data)
        if transpose { contents = contents.transpose() }
        self.xIndices = xIndices ?? Array(0..<data.count)
        self.yIndices = yIndices ?? Array(0..<data[0].count)
    }
    
    // `data` is organized so that each array within the array is a row of values with changing X values. If you are providing xIndices and yIndices that are "flipped" then be sure to set the `transpose` argument to true. (Note: `transpose` does *not* transpose xIndices and yIndices, unlike the `.transposed` computed property in this class)
    // If nil, `xIndices` and `yIndices` are assumed to be 0 to `data`'s width or height, respectively.
    init(data: [[ℝ]], xIndices: [Int]? = nil, yIndices: [Int]? = nil, transpose: Bool = false) {
        contents = Matrix(data.map{$0.map{ℝtoDouble($0)}})
        if transpose { contents = contents.transpose() }
        self.xIndices = xIndices ?? Array(0..<data.count)
        self.yIndices = yIndices ?? Array(0..<data[0].count)
    }
    
    // Unfinished and/or shouldn't exist:
//    init(X: SampleOrPopulation, Y: SampleOrPopulation, xIndices: [Int]? = nil, yIndices: [Int]? = nil) {
//        contents = Matrix(X.sampleOrPopulation.map{_ in Y.sampleOrPopulation.map{ℝtoDouble($0)}})
//        self.xIndices = xIndices ?? Array(0..<data.count)
//        self.yIndices = yIndices ?? Array(0..<data[0].count)
//    }
    
    // Sum of all values with the given fixed X index.
    func p_X(X: Int) -> ℝ {
        return doubleToℝ(contents.sumColumns()[yIndices.firstIndex(of: X)!])
    }
    
    // Sum of all values with the given fixed Y index.
    func p_Y(Y: Int) -> ℝ {
        return doubleToℝ(contents.sumRows()[yIndices.firstIndex(of: Y)!])
    }
    
    func p(_ x: Int, _ y: Int) -> ℝ {
        return doubleToℝ(contents[yIndices.firstIndex(of: y)!, xIndices.firstIndex(of: x)!])
    }
    
    func p_Y_given_X_of_y_given_x(x: Int, y: Int) -> ℝ {
        return p(x, y) / p_X(X: x)
    }
    
    // Same as E_Y_given_X
    func μ_Y_given_X(X: Int) -> ℝ {
        return yIndices.map{y in intToℝ(y) * p_Y_given_X_of_y_given_x(x: X, y: y)}.reduce(0, +)
    }
    
    // Returns the conditional expected value of Y given X = the given X.
    func E_Y_given_X(X: Int) -> ℝ {
        return μ_Y_given_X(X: X)
    }
    
    func p_X_given_Y_of_x_given_y(x: Int, y: Int) -> ℝ {
        return transposed.p_Y_given_X_of_y_given_x(x: y, y: x)
    }
    
    // Same as E_X_given_Y
    func μ_X_given_Y(Y: Int) -> ℝ {
        return transposed.μ_Y_given_X(X: Y)
    }
    
    // Returns the conditional expected value of X given Y = the given Y.
    func E_X_given_Y(Y: Int) -> ℝ {
        return μ_X_given_Y(Y: Y)
    }
    
    // "Mean for X"
    var μ_X: ℝ {
        xIndices.map{x in intToℝ(x) * p_X(X: x)}.reduce(0, +)
    }
    // "Mean for Y"
    var μ_Y: ℝ {
        yIndices.map{y in intToℝ(y) * p_Y(Y: y)}.reduce(0, +)
    }
    // (μ_{XY} = μ_X*μ_Y if X,Y are independent. This is because if they are independent, then X,Y are uncorrelated which means Cov(X,Y) is 0. Then, Cov(X,Y) is by definition μ_XY - μ_X * μ_Y so we know that μ_XY - μ_X * μ_Y = 0. Therefore the only way to get 0 here is if μ_XY = μ_X*μ_Y.
    var μ_XY: ℝ {
        // (Don't know how to do a nested for loop functionally..)
        var acc: ℝ = 0
        for x in xIndices {
            for y in yIndices { // (<--^ For all pairs x and y)
                acc += intToℝ(x) * intToℝ(y) * p(x, y)
            }
        }
        return acc
    }
    
    // Variance for X
    var variance_X: ℝ {
        let temp = xIndices.reduce(0, {acc, x in acc + intToℝ(x * x) * p_X(X: x)})
        return temp - μ_X * μ_X
    }
    
    // Variance for Y
    var variance_Y: ℝ {
        let temp = yIndices.reduce(0, {acc, y in acc + intToℝ(y * y) * p_Y(Y: y)})
        return temp - μ_Y * μ_Y
    }
    
    // Stdev for X
    var σ_X: ℝ { doubleToℝ(sqrt(ℝtoDouble(variance_X))) }
    
    // Stdev for Y
    var σ_Y: ℝ { doubleToℝ(sqrt(ℝtoDouble(variance_Y))) }
    
    // Covariance: Cov(X,Y)
    var cov: ℝ {
        μ_XY - μ_X * μ_Y
    }
    
    // Population correlation coefficient: ρ_{X,Y}
    var ρ_XY: ℝ {
        cov / (σ_X * σ_Y)
    }
    
    // "X and Y are independent if p(x,y) = p_X(x) * p_Y(y) for *all* x,y."
    var independent: Bool {
        // (Don't know how to do a nested for loop functionally..)
        for x in xIndices {
            for y in yIndices { // (<--^ For all pairs x and y)
                let res = p(x, y) == p_X(X: x) * p_Y(Y: y)
                if !res {
                    return false
                }
            }
        }
        return true
    }
    
    // Whether X and Y are correlated. (Note: a theorem is that if X and Y are independent then X and Y are uncorrelated (not correlated). Also note that the converse is not necessarily true.)
    var correlated: Bool { cov != 0 }
    // Whether X and Y are uncorrelated (cov == 0).
    var uncorrelated: Bool { !correlated }
    // Whether X and Y are positively correlated (implies correlated).
    var positivelyCorrelated: Bool { cov > 0 }
    // Whether X and Y are negatively correlated (implies correlated).
    var negativelyCorrelated: Bool { cov < 0 }
    
    // Returns a copy of `self` but X becomes Y (i.e. the rows become columns), and vice versa. Likewise, the X and Y indices are swapped (i.e., X becomes Y and Y becomes X)
    var transposed: JointPMF { JointPMF(data: contents.transpose().array, xIndices: yIndices, yIndices: xIndices) }
    
    var contents: Matrix // https://github.com/hollance/Matrix
    var xIndices: [Int]
    var yIndices: [Int]
}

// Single variable X
class PMF: JointPMF, SampleOrPopulation {
    var nOrN: Int { contents.count }
    
    var sampleOrPopulation: [ℝ] { contents.grid.map(doubleToℝ) }
    
    init(data: [Double], xIndices: [Int]? = nil) {
        super.init(data: [data], xIndices: xIndices, yIndices: xIndices)
    }
    
    var mean: ℝ { μ_X }
    
    var variance: ℝ { variance_X }
    
    var stdev: ℝ { σ_X }
}
