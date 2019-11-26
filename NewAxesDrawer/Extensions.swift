//
//  Extensions.swift
//  NewAxesDrawer
//
//  Created by Igor Kutovoy on 18.11.2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

import Cocoa

extension Double {
    var decomp:(value:Double,digit:Int) {
        let cnc = self.expStyle
        let eIndex = cnc.firstIndex(of: "e")
        let digit = Int(cnc[cnc.index(after: eIndex!)...cnc.index(before: cnc.endIndex)])
        let value = Double(cnc[cnc.startIndex...cnc.index(before: eIndex!)])
        return (value!,digit!)
    }

    struct Number {
        static var formatter = NumberFormatter()
    }
    var expStyle:String {
        Number.formatter.locale = Locale(identifier: "US")
        Number.formatter.numberStyle = .scientific
        Number.formatter.positiveFormat = "0.##E0"
        Number.formatter.exponentSymbol = "e"
        return Number.formatter.string(from: self as NSNumber) ?? description
    }
    var fixStyle:String {
        return String(format: "%4.2f", self)
    }
    var styled:String {
        if self >= 1000 || self <= 0.01 {
            return self.expStyle
        }
        else {
            return self.fixStyle
        }
    }
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    func roundTo(places:Int) -> CGFloat {
        let divisor = CGFloat(pow(10.0, Double(places)))
        return (self * divisor).rounded() / divisor
    }
    
    var decomp:(value:CGFloat,digit:Int) {
        var value = self
        var digit:Int
        if value < 1 {
            digit = Int(ceil(log10(self)) - 1.0)
            while value < 1 {
                value *= 10
            }
        }
        else {
            digit = Int((log10(self)))
            value = (self)/pow(10,CGFloat(digit))
        }

        return (value,digit)
    }
}

// https://stackoverflow.com/questions/10289898/drawing-rotated-text-with-nsstring-drawinrect/10293425
// Draw rotated NSString
extension NSString {
    func drawWithBasePoint(basePoint:CGPoint, angle:CGFloat) {
        let textSize = self.size(withAttributes: GConstants.markAttributes)
        let context = NSGraphicsContext.current?.cgContext
        
        let t:CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r:CGAffineTransform = CGAffineTransform(rotationAngle: angle)

        context!.concatenate(t)
        context!.concatenate(r)
        
        let position = CGPoint(x: -1 * textSize.width / 2, y: -1 * textSize.height)
        self.draw(at: position, withAttributes: GConstants.markAttributes)
        
        context!.concatenate(r.inverted())
        context!.concatenate(t.inverted())    
    }
}

extension NSAttributedString {
    func drawWithBasePoint(basePoint:CGPoint, angle:CGFloat) {
        let textSize = self.size()
        let context = NSGraphicsContext.current?.cgContext
        
        let t:CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r:CGAffineTransform = CGAffineTransform(rotationAngle: angle)

        context!.concatenate(t)
        context!.concatenate(r)
        
        let position = CGPoint(x: -1 * textSize.width / 2, y: -1 * textSize.height)
        self.draw(at: position)
        
        context!.concatenate(r.inverted())
        context!.concatenate(t.inverted())
    }
}
