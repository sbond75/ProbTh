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
    // If nil, `xIndices` and `yIndices` are assumed to be 0 to `data`'s width or height, respectively.
    init(data: [[Double]], xIndices: [Int]? = nil, yIndices: [Int]? = nil) {
        contents = Matrix(data)
        self.xIndices = xIndices ?? Array(0..<data.count)
        self.yIndices = yIndices ?? Array(0..<data[0].count)
    }
    
    // If nil, `xIndices` and `yIndices` are assumed to be 0 to `data`'s width or height, respectively.
    init(data: [[ℝ]], xIndices: [Int]? = nil, yIndices: [Int]? = nil) {
        contents = Matrix(data.map{$0.map{ℝtoDouble($0)}})
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
    
    // TODO: untested
    func p(_ x: Int, _ y: Int) -> ℝ {
        return doubleToℝ(contents[yIndices.firstIndex(of: y)!, xIndices.firstIndex(of: x)!])
    }
    
    // TODO: untested
    func p_Y_given_X_of_y_given_x(x: Int, y: Int) -> ℝ {
        return p(x, y) / p_X(X: x)
    }
    
    // TODO: untested
    // Same as E_Y_given_X
    func μ_Y_given_X(X: Int) -> ℝ {
        return yIndices.map{y in intToℝ(y) * p_Y_given_X_of_y_given_x(x: X, y: y)}.reduce(0, +)
    }
    
    // TODO: untested
    // Returns the conditional expected value of Y given X = the given X.
    func E_Y_given_X(X: Int) -> ℝ {
        return μ_Y_given_X(X: X)
    }
    
    // "Mean for X"
    var μ_X: ℝ {
        xIndices.map{x in intToℝ(x) * p_X(X: x)}.reduce(0, +)
    }
    // "Mean for Y"
    var μ_Y: ℝ {
        yIndices.map{y in intToℝ(y) * p_Y(Y: y)}.reduce(0, +)
    }
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
    
    // Covariance
    var cov: ℝ {
        μ_XY - μ_X * μ_Y
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
    
    var contents: Matrix // https://github.com/hollance/Matrix
    var xIndices: [Int]
    var yIndices: [Int]
}
