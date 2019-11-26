//
//  AxesDrawer.swift
//  NewAxesDrawer
//
//  Created by Igor Kutovoy on 18.11.2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

typealias TicksData = (digits:[Int],values:[CGFloat],labels:[String])
//typealias AxisData = (ticks: [TicksData], axisMinMax: [CGFloat], tickSpacing: CGFloat)
typealias NumDecomposed = (value:CGFloat,digit:Int)

import Cocoa

enum AxisScaleType {
    case lin,log
}
enum AxisOrientation {
    case horizontal, vertical
}

// MARK: - Base Axis lass
class AxesDrawer {
    // MARK: - Initialization
    var chartBounds:CGRect
    var chartInsets:NSEdgeInsets
    var gridEnabled: Bool
    var dataMinMax: [Double]
    var axisScaleType: AxisScaleType
    var axisOrientation: AxisOrientation
    var axisTitle: String

    init(chartBounds:CGRect,
        chartInsets:NSEdgeInsets,
        gridEnabled:Bool,
        dataMinMax: [Double],
        axisScaleType: AxisScaleType,
        axisOrientation: AxisOrientation,
        axisTitle: String) {
            self.chartBounds = chartBounds
            self.chartInsets = chartInsets
            self.gridEnabled = gridEnabled
            self.dataMinMax = dataMinMax
            self.axisScaleType  = axisScaleType
            self.axisOrientation = axisOrientation
            self.axisTitle = axisTitle
    }
    
    var major:TicksData = (digits:[Int](),values:[CGFloat](),labels:[String]())
    var minor:TicksData = (digits:[Int](),values:[CGFloat](),labels:[String]())
    
    var origin: NSPoint {
        return NSPoint(x: chartInsets.left, y: chartInsets.bottom)
    }
    
    let path = NSBezierPath()
    let gridPath = NSBezierPath()
    
    var axisMinMax:[CGFloat] = []
    var tickSpacing: CGFloat = 0

    var xAxisLength:CGFloat {
        return chartBounds.width - origin.x - chartInsets.right
    }
    var yAxisLength:CGFloat {
        return chartBounds.height - origin.y - chartInsets.top
    }
    // Size of major ticks step in axis coordinate space
    var step:CGFloat {
        var _step:CGFloat = 0.0
        switch axisOrientation {
        case .horizontal:
            _step = xAxisLength*GConstants.tickedAxisSpace/CGFloat(major.values.count - 1)
        case .vertical:
            _step = yAxisLength*GConstants.tickedAxisSpace/CGFloat(major.values.count - 1)
        }
        return _step
    }
    var delta:CGFloat = 0.0
    
    var majCoords = [CGFloat]()
    var minCoords = [CGFloat]()

    func getCoord(_ value:CGFloat) -> CGFloat {
        var coord: CGFloat = 0
        var mult: CGFloat = 0
        let a = log(axisMinMax[1])
        let b = log(axisMinMax[0])
        
        switch axisOrientation {
        case .horizontal:
            mult = xAxisLength*GConstants.tickedAxisSpace/(a - b)
            coord = (origin.x) + (log(value) - b)*mult
        case .vertical:
            mult = yAxisLength*GConstants.tickedAxisSpace/(a - b)
            coord = (origin.y) + (log(value) - b)*mult
        }
        return coord
    }
    
    func makeLine(path:NSBezierPath, fromPoint:NSPoint, toPoint:NSPoint) {
        path.lineWidth = 0.2
        path.move(to: fromPoint)
        path.line(to: toPoint)
    }
    
    func drawAxisBase() {
        var endPoint:NSPoint = NSPoint.zero
        switch axisOrientation {
        case .horizontal:
            endPoint = NSPoint(x: chartBounds.width - chartInsets.right, y: origin.y)
        case .vertical:
            endPoint = NSPoint(x: origin.x, y: chartBounds.height - chartInsets.top)
        }
        makeLine(path: path,
                 fromPoint: origin,
                 toPoint: endPoint)
        NSColor.textColor.setStroke()
        path.stroke()
    }
    
    func drawAxisTitle() {
        // Convert axisTitle to NSAttributedString for it's width and height
        switch axisOrientation {
        case .horizontal:
            let title = NSAttributedString(string: axisTitle)
            let titleHeight = title.size().height
            let titleWidth = title.size().width

            let titleRect = NSRect(
                x: origin.x + xAxisLength/2 - titleWidth/2,
                y: origin.y - 25 - titleHeight,
                width: titleWidth, height: titleHeight)
            axisTitle.draw(in: titleRect, withAttributes: GConstants.markAttributes)
        case .vertical:
            let title = axisTitle as NSString
            title.drawWithBasePoint(basePoint: CGPoint(x: chartInsets.left - 55, y: chartInsets.bottom + yAxisLength/2), angle: (.pi/2))
            title.size(withAttributes: GConstants.markAttributes)
        }
    }
    
    func drawWithBasePoint(title: NSString, basePoint:CGPoint, angle:CGFloat) {
        let textSize = title.size(withAttributes: GConstants.markAttributes)
        let context = NSGraphicsContext.current?.cgContext
        
        let t:CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r:CGAffineTransform = CGAffineTransform(rotationAngle: angle)

        context!.concatenate(t)
        context!.concatenate(r)
        
        let position = CGPoint(x: -1 * textSize.width / 2, y: -1 * textSize.height)
        title.draw(at: position, withAttributes: GConstants.markAttributes)
        
        context!.concatenate(r.inverted())
        context!.concatenate(t.inverted())
    }

    // MARK: - Required functions in subclasses
    func drawTicks() {}
    func drawLabels() {}
    func getAxis() {}
    
}

// MARK: - LinScaleAxis
class LinScaleAxis: AxesDrawer {
    
//MARK: - https://stackoverflow.com/questions/8506881/nice-label-algorithm-for-charts-with-minimum-ticks/16363437#16363437
    private var minPoint: CGFloat {
        return CGFloat(dataMinMax[0])
    }
    private var maxPoint: CGFloat {
        return CGFloat(dataMinMax[1])
    }
    private var maxTicks = 10
    private func getFraction(range: CGFloat, round: Bool) -> CGFloat {
        let exponent = floor(log10(range))
        let fraction = range / pow(10, exponent)
        let niceFraction: CGFloat

        if round {
            if fraction <= 1.5 {
                niceFraction = 1
            } else if fraction <= 3 {
                niceFraction = 2
            } else if fraction <= 7 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        } else {
            if fraction <= 1 {
                niceFraction = 1
            } else if fraction <= 2 {
                niceFraction = 2
            } else if fraction <= 5 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        }

        return niceFraction * pow(10, exponent)
    }

    override func drawTicks() {
        // MARK: - Draw major ticks & Grid lines
        drawMajorTicks()
        // MARK: - Draw minor ticks
        drawMinorTicks()
    }
    private func drawMajorTicks() {
        var point:CGFloat = 0.0
        NSColor.textColor.setStroke()
        for i in 1..<major.values.count {
            delta = 5
            switch axisOrientation {
            case .horizontal:
                point = origin.x + CGFloat(i)*step
                makeLine(path: path,
                         fromPoint: NSPoint(x:point, y: origin.y - delta),
                         toPoint: NSPoint(x:point, y: origin.y + delta))
            case .vertical:
                point = origin.y + CGFloat(i)*step
                makeLine(path: path,
                         fromPoint: NSPoint(x:origin.x - delta, y: point),
                         toPoint: NSPoint(x:origin.x + delta, y: point))
            }
            
            // Draw grid lines if gridEnabled == true
            
            if gridEnabled == true  {
                switch axisOrientation {
                case .horizontal:
                    // Major grid
                    makeLine(path: gridPath,
                    fromPoint: NSPoint(x:point, y: origin.y), // *** origin.y + delta
                    toPoint: NSPoint(x:point, y: origin.y + yAxisLength*GConstants.tickedAxisSpace))
                    // Minor grid
                    makeLine(path: gridPath,
                    fromPoint: NSPoint(x:point - step/2, y: origin.y), // *** origin.y + delta
                    toPoint: NSPoint(x:point - step/2, y: origin.y + yAxisLength*GConstants.tickedAxisSpace))
                case .vertical:
                    // Major grid
                    makeLine(path: gridPath,
                             fromPoint: NSPoint(x:origin.x, y: point),
                    toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: point))
                    // Minor grid
                    makeLine(path: gridPath,
                             fromPoint: NSPoint(x:origin.x, y: point - step/2),
                    toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: point - step/2))
                }
            }
        }
        path.stroke()
        
        if gridEnabled == true {
            gridPath.lineWidth = 0.1
            gridPath.stroke()
        }
    }
    private func drawMinorTicks() {
        var point:CGFloat = 0.0
        NSColor.textColor.setStroke()

        for i in 0..<minor.values.count {
                delta = 3.5
                switch axisOrientation {
                case .horizontal:
                    point = origin.x + step/2 + CGFloat(i)*step
                    makeLine(path: path,
                             fromPoint: NSPoint(x:point, y: origin.y - delta),
                             toPoint: NSPoint(x:point, y: origin.y + delta))
                case .vertical:
                    point = origin.y + step/2 + CGFloat(i)*step
                    makeLine(path: path,
                             fromPoint: NSPoint(x: origin.x - delta, y: point),
                             toPoint: NSPoint(x: origin.x + delta, y: point))
                }

            }
            path.stroke()
    }
    
    override func drawLabels() {
        // TODO: Meke improvements to markSize
        let markSize:NSSize = ("1000.00" as NSString).size(withAttributes: GConstants.labelAttr)
        var point:CGFloat = 0.0
        
        if major.labels[0] == "0e0" {
            major.labels[0] = "0.0"
        }

        for i in 0..<major.values.count {
            switch axisOrientation {
            case .horizontal:
                point = origin.x + CGFloat(i)*step - markSize.width/2
                let markRect = NSRect(x: point,
                                      y: origin.y - 20,
                                      width: markSize.width, height: markSize.height)
                major.labels[i].draw(in: markRect, withAttributes: GConstants.labelAttr)

            case .vertical:
                point = origin.y + CGFloat(i)*step - markSize.height/2
                let markRect = NSRect(x: origin.x - 20 - markSize.width/2 ,
                                      y: point,
                                      width: markSize.width, height: markSize.height)
                major.labels[i].draw(in: markRect, withAttributes: GConstants.labelAttr)
            }
        }
    }
    
    func getParameters() {
        var labelFormat: String = ""
        var range = getFraction(range: maxPoint - minPoint, round: false)
        tickSpacing = getFraction(range: range / CGFloat((maxTicks - 1)), round: true)
        
        let axisMin = floor(minPoint / tickSpacing) * tickSpacing
        let axisMax = ceil(maxPoint / tickSpacing) * tickSpacing

        range = axisMax - axisMin
        if maxPoint > axisMax {
            axisMinMax = [axisMin, maxPoint]
        } else {
            axisMinMax = [axisMin, axisMax]
        }
        
        var majorValues: [CGFloat] = []
        var minorValues: [CGFloat] = []

        let numberOfMajor = Int((axisMinMax[1] - axisMinMax[0])/tickSpacing)

        majorValues.append(axisMinMax[0])
        for i in 1...Int(numberOfMajor) {
            majorValues.append(majorValues[i-1] + tickSpacing)
        }
        major.digits = []
        major.values = majorValues.map{$0.roundTo(places: 2)}

        if axisMinMax[1] <= 200 {
            labelFormat = "%4.2f"
        } else {
            labelFormat = "%4.0f"
        }
        major.labels = major.values.map{String(format: labelFormat, Double($0))}

        minorValues.append(axisMinMax[0] + tickSpacing/2 )
        for i in 1..<Int(numberOfMajor) {
            minorValues.append(minorValues[i-1] + tickSpacing)
        }
        minor.digits = []
        minor.values = minorValues.map{$0.roundTo(places: 2)}
        minor.labels = minor.values.map{Double($0).styled}
    }
    
    override func getAxis() {
        drawAxisBase()
        _ = getParameters()
        drawTicks()
        drawLabels()
        drawAxisTitle()
    }

}

class LogScaleAxis: AxesDrawer {

    var minY:NumDecomposed { return axisMinMax[0].decomp }
    var maxY:NumDecomposed { return axisMinMax[1].decomp }

    private func getYAxisMinMax() -> [CGFloat] {
        let minValRounded = roundDown(dataMinMax[0].decomp.value, toNearest: 0.01)
        let minDigit = dataMinMax[0].decomp.digit
        let maxValRounded = roundUp(dataMinMax[1].decomp.value, toNearest: 0.01)
        let maxDigit = dataMinMax[1].decomp.digit
        
        let yAxisMin = minValRounded < 2 ? pow(10,Double(minDigit)) : minValRounded*pow(10,Double(minDigit))
        let yAxisMax = maxValRounded >= 8 ? pow(10,Double(maxDigit + 1)) : maxValRounded*pow(10,Double(maxDigit))
        return [yAxisMin,yAxisMax].map{CGFloat($0)}
    }
    
    override func drawTicks() {
        // MajorTicks & Grid
        drawMajorTicks()
        // MinorTicks & Grid
        drawMinorTicks()
    }
    
    override func drawLabels() {
        var mark:NSString = ""
        var markSize = NSSize()
        var markRect = NSRect()
        
        // Y Major Labels
        delta = 5.0
        if major.labels.count > 0 {
            for i in 0..<major.labels.count {
                mark = major.labels[i] as NSString
                markSize = mark.size(withAttributes: GConstants.labelAttr)
                switch axisOrientation {
                case .horizontal:
                    markRect = NSRect(x: majCoords[i] - markSize.width/2,
                                      y: origin.y - 3 - delta - markSize.height,
                                      width : markSize.width, height: markSize.height)
                    mark.draw(in: markRect, withAttributes: GConstants.labelAttr)
                case .vertical:
                    markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                                      y: majCoords[i] - markSize.height/2,
                                      width : markSize.width, height: markSize.height)
                    mark.draw(in: markRect, withAttributes: GConstants.labelAttr)
                }
                
            }
        }
        
        // Y Minor Labels (Draw zero & Last labels)
        // Zero Label: if decomposed "value before digit" for minimum greater than 8 text labels will be too close -> so ignore minimum label in this case
        
        let valueLessThenEight = axisMinMax[0].decomp.value >= 2
        if valueLessThenEight {
            mark = Double(axisMinMax[0]).styled as NSString
            markSize = mark.size(withAttributes: GConstants.labelAttr)
            switch axisOrientation {
            case .horizontal:
                markRect = NSRect(x: origin.x - markSize.width/2,
                y: origin.y - 3 - delta - markSize.height,
                width : markSize.width, height: markSize.height)
            case .vertical:
                markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                y: origin.y - markSize.height/2,
                width : markSize.width, height: markSize.height)
            }
            
            mark.draw(in: markRect, withAttributes: GConstants.labelAttr)
        }
        
        // Last Label
        let lastStrMin = String(format: "%4.2e", minor.values.last!)
        var lastStrMaj = ""
        var lastLabel = ""
        var lastCoord:CGFloat = 0.0
        if major.values != [] {
            lastStrMaj = String(format: "%4.2e", major.values.last!)
            if major.values.last! < minor.values.last! {
                lastLabel = lastStrMin
                lastCoord = minCoords.last!
            } else {
                lastLabel = lastStrMaj
                lastCoord = majCoords.last!
            }
//            lastLabel = major.values.last! < minor.values.last! ? lastStrMin : lastStrMaj
//            lastCoord = major.values.last! < minor.values.last! ? minCoords.last! : majCoords.last!
            if Double(lastLabel) != Double(major.labels.last!) {
                mark = lastLabel as NSString
                markSize = mark.size(withAttributes: GConstants.labelAttr)
                switch axisOrientation {
                case .horizontal:
                    markRect = NSRect(x: lastCoord - markSize.width/2,
                        y: origin.y  - 3 - delta - markSize.height,
                    width : markSize.width, height: markSize.height)
                case .vertical:
                    markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                    y: lastCoord - markSize.height/2,
                    width : markSize.width, height: markSize.height)
                }
                mark.draw(in: markRect, withAttributes: GConstants.labelAttr)
            }
        }
        
        
    }
    
    func drawMajorTicks() {
        // MajorTicks & Grid
        if major.values != [] {
            majCoords = major.values.map{ getCoord($0) }
            delta = 5.0
            for i in 0..<majCoords.count {
                switch axisOrientation {
                case .horizontal:
                    makeLine(path: path, fromPoint: NSPoint(x: majCoords[i], y: origin.y - delta),
                             toPoint: NSPoint(x: majCoords[i], y: origin.y + delta))
                    if gridEnabled == true {
                        makeLine(path: gridPath, fromPoint: NSPoint(x: majCoords[i], y: origin.y + delta),
                                 toPoint: NSPoint(x: majCoords[i], y: origin.y + yAxisLength*GConstants.tickedAxisSpace))
                    }
                case .vertical:
                    makeLine(path: path, fromPoint: NSPoint(x: origin.x - delta, y: majCoords[i]),
                             toPoint: NSPoint(x: origin.x + delta, y: majCoords[i]))
                    if gridEnabled == true {
                        makeLine(path: gridPath, fromPoint: NSPoint(x: origin.x + delta, y: majCoords[i]),
                                 toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: majCoords[i]))
                    }
                }
            }
            path.stroke()
            
            if gridEnabled == true {
                gridPath.lineWidth = 0.1
                gridPath.stroke()
            }
        }
    }
    
    func drawMinorTicks() {
        minCoords =  minor.values.map{ getCoord($0) }
        delta = 3.5
        for i in 0..<minCoords.count {
            switch axisOrientation {
            case .horizontal:
                makeLine(path: path, fromPoint: NSPoint(x: minCoords[i], y: origin.y - delta),
                         toPoint: NSPoint(x: minCoords[i], y: origin.y + delta))
                if gridEnabled == true {
                    makeLine(path: gridPath, fromPoint: NSPoint(x: minCoords[i], y: origin.y + delta),
                             toPoint: NSPoint(x: minCoords[i], y: origin.y + yAxisLength*GConstants.tickedAxisSpace))
                }
            case .vertical:
                makeLine(path: path, fromPoint: NSPoint(x: origin.x - delta, y: minCoords[i]),
                         toPoint: NSPoint(x: origin.x + delta, y: minCoords[i]))
                if gridEnabled == true {
                    makeLine(path: gridPath, fromPoint: NSPoint(x: origin.x + delta, y: minCoords[i]),
                             toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: minCoords[i]))
                }
            }

        }
        path.stroke()
        if gridEnabled == true {
            gridPath.lineWidth = 0.1
            gridPath.stroke()
        }
    }
    
    func getParameters() {
        axisMinMax = getYAxisMinMax()
        major.digits = getMajorDigits()
        major.values = getMajorValues()
        major.labels = major.values.map{Double($0).styled}
        minor.digits = getMinorDigits()
        minor.values = getMinorValues()

    }
    
    override func getAxis() {
        drawAxisBase()
        _ = getParameters()
        drawAxisBase()
        drawTicks()
        drawLabels()
        drawAxisTitle()
    }
    
    private func roundUp(_ number: Double, toNearest: Double) -> Double {
        return ceil(number / toNearest) * toNearest
    }
    private func roundDown(_ number: Double, toNearest: Double) -> Double {
        return floor(number / toNearest) * toNearest
    }
}

extension LogScaleAxis {
    func getMajorDigits() -> [Int] {
        var majorDigits = [minY.digit,maxY.digit]
        let n = maxY.digit - minY.digit
        if n > 1 {
            for i in 1..<n {
                majorDigits.insert(majorDigits[0] + i, at: i)
            }
        }
        if n == 0 {majorDigits.removeLast()}
        if minY.value >= 2 {majorDigits.remove(at: 0)}
        return majorDigits
    }
    func getMajorValues() -> [CGFloat] {
        var majorValues = [CGFloat]()
        if major.digits != [] {
            majorValues = major.digits.map{pow(10.0,CGFloat($0))}
        }
        return majorValues
    }
    func getMinorDigits() -> [Int] {
        var minorDigits = [Int]()
        if major.digits == [] {
            minorDigits.append(maxY.digit)
        }
        else {
            minorDigits = major.digits
            if minY.digit < major.digits[0]  && Int(minY.value) != 9 {
                minorDigits.insert(minY.digit, at: 0)
            }
        }
        return minorDigits
    }
    func getMinorValues() -> [CGFloat] {
        let outerLoops = minor.digits.count == 1 ? 0 : minor.digits.count - 1
        var minorValues = [CGFloat]()
        var startInnerLoopIndex = 0
        var endInnerLoopIndex = 0

        for i in 0...outerLoops {
            if i == 0 { // Все данные в пределах одного степенного диапазона
                startInnerLoopIndex = (Int(minY.value) != 1) && (Int(minY.value) != 9) ? Int(ceil(minY.value)) : 2
                endInnerLoopIndex = outerLoops != 0 ? 9 : Int(maxY.value)
                if endInnerLoopIndex < startInnerLoopIndex {
                    minorValues.append(pow(10.0,CGFloat(minor.digits[i])))
                }
                else {
                    for j in startInnerLoopIndex...endInnerLoopIndex {
                        minorValues.append(CGFloat(j)*pow(10.0,CGFloat(minor.digits[i])))
                    }
                }
            }
            if i > 0 && i < outerLoops {    // Промежуточные степенные диапазоны
                startInnerLoopIndex = 2
                endInnerLoopIndex = 9
                for j in startInnerLoopIndex...endInnerLoopIndex {
                    minorValues.append(CGFloat(j)*pow(10.0,CGFloat(minor.digits[i])))
                }
            }
            if i == outerLoops && outerLoops != 0 { // Последний степенной диапазон
                startInnerLoopIndex = Int(maxY.value) > 1 ? 2 : 0
                if startInnerLoopIndex != 0 {
                    endInnerLoopIndex = Int(maxY.value)
                    for j in startInnerLoopIndex...endInnerLoopIndex {
                        minorValues.append(CGFloat(j)*pow(10.0,CGFloat(minor.digits[outerLoops])))
                    }
                }
            }
        }
        return minorValues
    }
}
