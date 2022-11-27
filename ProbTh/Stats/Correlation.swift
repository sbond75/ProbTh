//
//  Correlation.swift
//  ProbTh
//
//  Created by sbond75 on 11/17/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

func correlation(_ xAndY: [(R, R)]) -> R {
    return correlation(Sample(xAndY.map{$0.0}), Sample(xAndY.map{$0.1}))
}

func correlation(_ s1: Sample, _ s2: Sample) -> R {
    assert(s1.nOrN == s2.nOrN)
    let sum1 = (1...s1.nOrN).reduce(0, {acc,i in acc + s1.sampleOrPopulation.i(i) * s2.sampleOrPopulation.i(i)})
    let secondTerm = intToℝ(s1.nOrN) * s1.mean * s2.mean
    let sum2 = (1...s1.nOrN).reduce(0, {acc,i in acc + s1.sampleOrPopulation.i(i) * s1.sampleOrPopulation.i(i)})
    let sum3 = (1...s2.nOrN).reduce(0, {acc,i in acc + s2.sampleOrPopulation.i(i) * s2.sampleOrPopulation.i(i)})
    let denom1 = sqrt(sum2 - intToℝ(s1.nOrN) * (s1.mean * s1.mean))
    let denom2 = sqrt(sum3 - intToℝ(s2.nOrN) * (s2.mean * s2.mean))
    return (sum1 - secondTerm) / (denom1 * denom2)
}
