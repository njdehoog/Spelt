//
//  NSRegularExpression+Utilities.swift
//  Spelt
//
//  Created by Niels de Hoog on 25/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation


extension NSRegularExpression {
    func stringForFirstMatch(_ text: String, options: NSRegularExpression.MatchingOptions, rangeAtIndex: Int = 0) -> String? {
        let nsString = text as NSString
        if let result = firstMatch(in: text, options: options, range: NSMakeRange(0, nsString.length)) {
            return nsString.substring(with: result.range(at: rangeAtIndex))
        }
        return nil
    }
}
