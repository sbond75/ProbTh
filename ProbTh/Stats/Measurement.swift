//
//  Measurement.swift
//  ProbTh
//
//  Created by sbond75 on 9/15/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

class Measurement: ExpressibleByStringLiteral, CustomStringConvertible {
    init(value: ℝ, uncertainty: ℝ) {
        self.value = value
        self.uncertainty = uncertainty
    }
    
    required init(stringLiteral value: String) {
        let res = value.split(separator: "±")
        self.value = stringToℝ(String(res[0]))
        self.uncertainty = stringToℝ(String(res[1]))
    }
    
    var description: String {
        "\(value)±\(uncertainty)"
    }
    
    var value: ℝ
    var uncertainty: ℝ
}

// WRONG?: need derivatives..
//func * (left: ℝ, right: Measurement) -> Measurement {
//    return Measurement(value: left * right.value, uncertainty: left * right.uncertainty)
//}
//
//func * (left: Measurement, right: Measurement) -> Measurement {
//    return Measurement(value: left.value * right.value, uncertainty: left.uncertainty * right.uncertainty)
//}
