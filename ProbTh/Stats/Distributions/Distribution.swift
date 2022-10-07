//
//  Distribution.swift
//  ProbTh
//
//  Created by sbond75 on 10/5/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation

protocol Distribution {
    associatedtype T
    
    func p(XIsExactly x: T) -> __0iTo1i
    
    func p(XIsGreaterThan x: T) -> __0iTo1i
    
    func p(XIsLessThan x: T) -> __0iTo1i
}
