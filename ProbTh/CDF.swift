//
//  CDF.swift
//  ProbTh
//
//  Created by sbond75 on 8/20/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// Cumulative distribution functions

import Foundation
import Bow

// Inclusive 0 to 1.
@propertyWrapper struct _0iTo1i<T: Numeric & Comparable & CustomStringConvertible> {
    var value: T

    var wrappedValue: T {
        get { value }

        set {
            assert(newValue >= 0)
            assert(newValue <= 1)
            value = newValue
        }
    }

    init(wrappedValue: T) {
        assert(wrappedValue >= 0)
        assert(wrappedValue <= 1 || wrappedValue.description.starts(with: "1.000000")) // Hack to get it to work on edge cases
        //assert(wrappedValue <= 1)
        self.value = wrappedValue
    }
}

//typealias __0iTo1i = _0iTo1i<ℝ>
struct __0iTo1i {
    @_0iTo1i var ℝ_0to1: ℝ
}

// "A cumulative distribution function (CDF) is a function FX : R → [0, 1] which specifies a proba-
// bility measure as," "Fₓ (x) = P (X ≤ x)" where `=` is "by definition". :
// func Fₓ(x: ℝ, P: P) -> __0iTo1i
typealias Fₓ = Function1<ℝ, __0iTo1i>

// Properties of Fₓ
class Fₓ_props: Theory {
    var properties: [Property] { return [
        "0 ≤ Fₓ(x) ≤ 1",
        "lim_{x→−∞} Fₓ(x) = 0",
        "lim_{x→∞} Fₓ(x) = 1",
        "x ≤ y ⇒ Fₓ(x) ≤ Fₓ(y)"
    ]}
}
