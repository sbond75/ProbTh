//
//  Poisson.swift
//  ProbTh
//
//  Created by sbond75 on 9/25/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import Accelerate
import BigInt

class Poisson {
    init(items: R, per timeUnit: R) {
        self.rate = items / timeUnit
    }
    
    func prob(nItems: Int, inNext timeUnits: R) -> __0iTo1i {
        return p(x: nItems, inNext: timeUnits)
    }
    
    func p(x: Int, inNext lambda: R = 1.0) -> __0iTo1i {
        let lambdaPrime = rate * lambda
        return __0iTo1i(ℝ_0to1: doubleToℝ(exp(ℝtoDouble(-lambdaPrime)) * pow(ℝtoDouble(lambdaPrime), Double(x)) / Double(factorial(x)))) // TODO: more precision than Double when converting factorial
    }
    
    var rate: R
}
