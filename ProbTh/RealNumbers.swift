//
//  RealNumbers.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import BigInt

// Not truly real numbers but since inputs usually take the form of base-10 numbers, we define real numbers as that instead of base-2 with Doubles.

// Basic definitions and conversion functions (like "axioms")
//typealias R = NSDecimalNumber
typealias R = Decimal // https://developer.apple.com/documentation/foundation/decimal , base-10 number
typealias ℝ = R

//typealias R = Double
//func ℝtoDouble(_ ℝ: ℝ) -> Double {
//    return ℝ
//}

func ℝtoDouble(_ ℝ: ℝ) -> Double {
    return NSDecimalNumber(decimal: ℝ).doubleValue
}

func doubleToℝ(_ double: Double) -> ℝ {
    return Decimal(double)
}
func intToℝ(_ int: Int) -> ℝ {
    return Decimal(int)
}
func stringToℝ(_ string: String) -> ℝ {
    return Decimal(string: string)!
}

func bigIntToℝ(_ bigInt: BigInt) -> ℝ {
    return Decimal(string: String(bigInt))!
}
// //

// General ℝ functions
extension ℝ {
    var integerAndFractionParts: (ℝ, ℝ) {
        let value = self
        let doubleValue = ℝtoDouble(value)
        let integerPart = floor(doubleValue)
        return (ℝ(integerPart), ℝ(doubleValue - integerPart))
    }
}

// Some of these lose base-10 and goes to base-2 and back so some significant figures may be lost etc. //
func pow(_ x: R, _ p: R) -> R {
    return doubleToℝ(pow(ℝtoDouble(x), ℝtoDouble(p)))
}
func pow(_ x: R, _ p: Int) -> R {
    return doubleToℝ(pow(ℝtoDouble(x), Double(p)))
}
func sqrt(_ x: R) -> R {
    return doubleToℝ(sqrt(ℝtoDouble(x)))
}
// //
