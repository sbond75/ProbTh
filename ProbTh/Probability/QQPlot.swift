//
//  QQPlot.swift
//  ProbTh
//
//  Created by sbond75 on 10/2/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import SwiftPlot
import QuartzRenderer

// Also known as "probability plot"
class QQPlot {
    let renderer = QuartzRenderer()
    
    func plot(sample: Sample) {
        // Axes
        var x = [Double]()
        x.reserveCapacity(sample.nOrN)
        var y = [Double]()
        y.reserveCapacity(sample.nOrN)
        
        let mean = sample.mean
        let stdev = sample.stdev
        for i in 1...sample.nOrN {
            let p = (intToℝ(i) - 0.5) / intToℝ(sample.nOrN)
            //sample.pthPercentile(p: __0iTo1i(ℝ_0to1: p))
            let percentile = doubleToℝ(Normal.zscore(for: ℝtoDouble(p)))
            let Q_i = mean + stdev * percentile
            // ^"quantile"
            //print(p, percentile, Q_i)
            x.append(ℝtoDouble(sample.sorted.i(i)))
            y.append(ℝtoDouble(Q_i))
        }

        //print(x)
        //print(y)

        // https://github.com/KarthikRIyer/swiftplot#documentation
        var lineGraph = ScatterPlot<Double,Double>() //LineGraph<Double,Double>(enablePrimaryAxisGrid: true)
        lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
        lineGraph.plotTitle.title = "QQ Plot"
        lineGraph.plotLabel.xLabel = "Xᵢ"
        lineGraph.plotLabel.yLabel = "Qᵢ"
        //lineGraph.plotLineThickness = 3.0
        do {
            try lineGraph.drawGraphAndOutput(fileName: "/Volumes/MyTestVolume/Projects/LearningCoq/MyProbabilityTheoryProver/ProbTh/out"/*`.png` gets appended automatically*/, renderer: renderer)
        } catch let e {
            print(e)
        }
        
        //exit(0)
    }
}
