//
//  GConstants.swift
//  NewAxesDrawer
//
//  Created by Igor Kutovoy on 18.11.2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

import Cocoa

class GConstants {
    static let chartTitle = ["DOPANT DENSITIES DISTRIBUTION",
                             "NET DENSITY DISTRIBUTION",
                             "SPECIFIC RESISTIVITY DISTRIBUTION",
                             "COMPENSATION LEVEL DISTRIBUTION"]
    static let yAxisTitle = ["Dopant Density, (at/cm3)", "Net Density, (at/cm3)", "Resistivity, (Ohm∙cm)","Compensation level"]

    static let tickedAxisSpace:CGFloat = 0.98
    
    static var markAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        return  [NSAttributedString.Key.font: NSFont(name: "Helvetica Light", size:12)!,
                 NSAttributedString.Key.foregroundColor: NSColor.labelColor,
                 NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }
    
    static var labelAttr: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        return  [NSAttributedString.Key.font: NSFont(name: "Helvetica Light", size:10)!,
                 NSAttributedString.Key.foregroundColor: NSColor.labelColor,
                 NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }
    
    static let pTypeColor = NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.07)
    static let nTypeColor = NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 0.07)
    
    static let pTColor: NSColor  =  NSColor(named: "pColor")!
  
}

