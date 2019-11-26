//
//  GraphView.swift
//  NewAxesDrawer
//
//  Created by Igor Kutovoy on 18.11.2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

import Cocoa



class GraphView: NSView {
    
    var context:CGContext?
    
    // MARK: - TEST Data: arrays of min, max values for X- and Y-data
    // (Without code for min/max values calculation)
    let xDataMinMax:[Double] = [0.1,1.0]
    let yDataMinMax:[Double] = [1.67e16, 6.34e18]
    let chartInsets = NSEdgeInsets(top: 60, left: 80, bottom: 50, right: 40)
    
    // linTip get value from NSSegmentedControl (in ViewController).
    // Axes redrawn in func draw(_ dirtyRect: NSRect)
    var lineTip: Int = 0 {
        didSet {
            needsDisplay = true
        }
    }
    
   
    override func draw(_ dirtyRect: NSRect) {
        
//        context = NSGraphicsContext.current?.cgContext
        
        super.draw(dirtyRect)

        switch lineTip {
        case 0:
            makeHLinVLog()
        case 1:
            makeHLogVLin()
        case 2:
            makeAllLin()
        default:
            makeAllLog()
        }
    }
    
    func makeHLinVLog() {
        makeLinHAxis(chartInsets: chartInsets, dataMinMax: xDataMinMax)
        makeLogVAxis(chartInsets: chartInsets, dataMinMax: yDataMinMax)
    }
    func makeHLogVLin() {
        makeLogHAxis(chartInsets: chartInsets, dataMinMax: yDataMinMax)
        makeLinVAxis(chartInsets: chartInsets, dataMinMax: xDataMinMax)
    }
    func makeAllLin() {
        testXAxis(chartInsets: chartInsets, dataMinMax: xDataMinMax)
    }
    func makeAllLog() {
        testYAxis(chartInsets: chartInsets, dataMinMax: yDataMinMax)
    }
    
//    func makeLinHAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        let axis = LinScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .lin,
//                                 axisOrientation: .horizontal,
//                                 axisTitle: "Title for Linear, Horizontal")
//        axis.getAxis()
//    }
//    func makeLinVAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        let axis = LinScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .lin,
//                                 axisOrientation: .vertical,
//                                 axisTitle: "Title for Linear, Vertical")
//        axis.getAxis()
//    }
//    func makeLogHAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        let axis = LogScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .log,
//                                 axisOrientation: .horizontal,
//                                 axisTitle: "Title for Log, Horizontal")
//        axis.getAxis()
//    }
//    func makeLogVAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        let axis = LogScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .log,
//                                 axisOrientation: .vertical,
//                                 axisTitle: "Title for Log, Vertical")
//        axis.getAxis()
//    }
//    func testXAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        // Test: Linear, Horizontal
//        var axis = LinScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .lin,
//                                 axisOrientation: .horizontal,
//                                 axisTitle: "Title for horizontal axe")
//        axis.getAxis()
//        
//        // Test: Linear, Vertical
//        axis = LinScaleAxis(chartBounds: bounds,
//                             chartInsets: chartInsets, gridEnabled: true,
//                             dataMinMax: dataMinMax,
//                             axisScaleType: .lin,
//                             axisOrientation: .vertical,
//                             axisTitle: "Title for vertical axe")
//        axis.getAxis()
//    }
//    func testYAxis(chartInsets: NSEdgeInsets, dataMinMax: [Double]) {
//        // Test: Linear, Horizontal
//        var axis = LogScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .log,
//                                 axisOrientation: .horizontal,
//                                 axisTitle: "Horizontal Y-Axis title")
//        axis.getAxis()
//        
//        axis = LogScaleAxis(chartBounds: bounds,
//                                 chartInsets: chartInsets,
//                                 gridEnabled: true,
//                                 dataMinMax: dataMinMax,
//                                 axisScaleType: .log,
//                                 axisOrientation: .vertical,
//                                 axisTitle: "Vertical Y-Axis title")
//        axis.getAxis()
//    }
    
}
