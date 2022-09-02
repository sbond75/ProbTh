//
//  HW1.swift
//  ProbTh
//
//  Created by sbond75 on 8/31/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// 1.2#10
//let _12_10 = Sample( // "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
//    Array<ℝ>(repeating: 1, count: 70) +
//    Array<ℝ>(repeating: 2, count: 15) +
//    Array<ℝ>(repeating: 3, count: 10) +
//    Array<ℝ>(repeating: 4, count: 3) +
//    Array<ℝ>(repeating: 5, count: 2)
//)
let _12_10 = Sample( // This fixes "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions" (the above version has this issue)
    Array<ℝ>(repeating: 1, count: 70).combine(
    Array<ℝ>(repeating: 2, count: 15)) +
       Array<ℝ>(repeating: 3, count: 10) +
       Array<ℝ>(repeating: 4, count: 3) +
       Array<ℝ>(repeating: 5, count: 2)
)

// 1.3#1
let _13_1 = Sample([
0.2,
 3.7,
 1.2,
 13.7,
 1.5,
 0.2,
 1.7,
0.6,
 0.1,
 8.9,
 1.9,
 5.5,
 0.5,
 3.1,
3.1,
 8.9,
 8.0,
 12.7,
 4.1,
 0.3,
 2.6,
1.5,
 8.0,
 4.6,
 0.7,
 0.7,
 6.6,
 4.9,
0.1,
 4.4,
 3.2,
 11.0,
 7.9,
 0.0,
 1.3,
2.4,
 0.1,
 2.8,
 4.9,
 3.5,
 6.1,
 0.1

])

let _13_5_catalyst1 = Sample([
    4.4,
     3.4,
     2.6,
     3.8,
    4.9,
     4.6,
     5.2,
     4.7,
    4.1,
     2.6,
     6.7,
     4.1,
    3.6,
     2.9,
     2.6,
     4.0,
    4.3,
     3.9,
     4.8,
     4.5,
    4.4,
     3.1,
     5.7,
     4.5
])

let _13_5_catalyst2 = Sample([
    3.4,
     1.1,
     2.9,
     5.5,
    6.4,
     5.0,
     5.8,
     2.5,
    3.7,
     3.8,
     3.1,
     1.6,
    3.5,
     5.9,
     6.7,
     5.2,
    6.3,
     2.6,
     4.3,
     3.8
])

let _13_19 = Sample(
    Array<R>(repeating: 0, count: 10).combine(Array<R>(repeating: 1, count: 7)) +
    [2, 2, 2, 3]
)

let _3 = Sample([9997, 10000, 10000, 10003])
