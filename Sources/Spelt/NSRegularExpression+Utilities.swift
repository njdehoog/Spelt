//
//  NSRegularExpression+Utilities.swift
//  Spelt
//
//  Created by Niels de Hoog on 25/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation


extension NSRegularExpression {
    func stringForFirstMatch(text: String, options: NSMatchingOptions, rangeAtIndex: Int = 0) -> String? {
        let nsString = text as NSString
        if let result = self.firstMatchInString(text, options: options, range: NSMakeRange(0, nsString.length)) {
            return nsString.substringWithRange(result.rangeAtIndex(rangeAtIndex))
        }
        return nil
    }
}