//
//  HW3.swift
//  ProbTh
//
//  Created by sbond75 on 9/14/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

// 2.4#3
// (This is actually just PMF, not Joint PMF, but it shows how JointPMF can be used as a superset of PMF stuff:)
//let _24_3 = JointPMF(data:[[0.4,0.2,0.2,0.1,0.1]], xIndices: Array(1...5), yIndices: Array(1...5))
let _24_3 = PMF(data:[0.4,0.2,0.2,0.1,0.1], xIndices: Array(1...5))
let _24_3d = PMF(data:[0.4,0.2,0.2,0.1,0.1], xIndices: (1...5).map{$0 * 10})
