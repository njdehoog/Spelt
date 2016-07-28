//
//  String+Paths.swift
//  Spelt
//
//  Created by Niels de Hoog on 19/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

/**
* Provide NSString path extensions, because Swift no longer bridges to NSString automatically
* See: https://forums.developer.apple.com/thread/13580
*/

public extension String {
    var stringByDeletingPathExtension:String {
        return (self as NSString).stringByDeletingPathExtension;
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        return (self as NSString).stringByAppendingPathExtension(ext)
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
    
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    static func pathWithComponents(components: [String]) -> String {
        return NSString.pathWithComponents(components) as String
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).stringByDeletingLastPathComponent
    }
    
    var stringByDeletingTrailingSlash: String {
        if self.hasSuffix("/") {
            return self.substringToIndex(self.endIndex.predecessor())
        }
        return self
    }
    
    var stringByExpandingTildeInPath: String {
        return (self as NSString).stringByExpandingTildeInPath
    }
}

// Add method for extracting root domain

public extension String {
    
    var pathByExtractingRootDomain: String? {
        let components = self.componentsSeparatedByString(".")
        guard components.count > 1 else {
            return nil
        }
        
        // return last 2 components
        return components.suffix(2).joinWithSeparator(".")
    }
}


// Add some extra path utility methods

public extension String {
    func stringByDeletingPathComponents(components: [String]) -> String {
        let filteredComponents = self.pathComponents.filter() { component in
            return components.indexOf(component) == nil
        }
        return String.pathWithComponents(filteredComponents)
    }
    
    func pathRelativeToPath(basePath: String) -> String {
        // NOTE: will only work if path is longer than basePath. i.e. will not return '../../path' type paths
        return stringByDeletingPathComponents(basePath.pathComponents).lowercaseString
    }
    
    func stringByReplacingPathExtension(withExtension ext: String) -> String? {
        return stringByDeletingPathExtension.stringByAppendingPathExtension(ext)
    }
    
    func isSubpath(ofPath path: String) -> Bool {
        let trimmedPath = stringByDeletingTrailingSlash
        let trimmedParentPath = path.stringByDeletingTrailingSlash
        guard let range = trimmedPath.rangeOfString(trimmedParentPath, options: [.AnchoredSearch, .CaseInsensitiveSearch]) where range.startIndex == trimmedPath.startIndex else {
            return false
        }
        return true
    }
}