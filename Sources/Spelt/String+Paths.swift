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
        return (self as NSString).deletingPathExtension;
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        return (self as NSString).appendingPathExtension(ext)
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    static func pathWithComponents(_ components: [String]) -> String {
        return NSString.path(withComponents: components) as String
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var stringByDeletingTrailingSlash: String {
        if hasSuffix("/") {
            return String(self[..<endIndex])
        }
        return self
    }
    
    var stringByExpandingTildeInPath: String {
        return (self as NSString).expandingTildeInPath
    }
    
    var stringByStandardizingPath: String {
        return (self as NSString).standardizingPath
    }
}

// Add method for extracting root domain

public extension String {
    
    var pathByExtractingRootDomain: String? {
        let components = self.components(separatedBy: ".")
        guard components.count > 1 else {
            return nil
        }
        
        // return last 2 components
        return components.suffix(2).joined(separator: ".")
    }
}


// Add some extra path utility methods

public extension String {
    func stringByDeletingPathComponents(_ components: [String]) -> String {
        let filteredComponents = self.pathComponents.filter() { component in
            return components.index(of: component) == nil
        }
        return String.pathWithComponents(filteredComponents)
    }
    
    func pathRelativeToPath(_ basePath: String) -> String {
        // NOTE: will only work if path is longer than basePath. i.e. will not return '../../path' type paths
        return stringByDeletingPathComponents(basePath.pathComponents).lowercased()
    }
    
    func stringByReplacingPathExtension(withExtension ext: String) -> String? {
        return stringByDeletingPathExtension.stringByAppendingPathExtension(ext)
    }
    
    func isSubpath(ofPath path: String) -> Bool {
        let trimmedPath = stringByDeletingTrailingSlash
        let trimmedParentPath = path.stringByDeletingTrailingSlash
        guard let range = trimmedPath.range(of: trimmedParentPath, options: [.anchored, .caseInsensitive]) , range.lowerBound == trimmedPath.startIndex else {
            return false
        }
        return true
    }
}

// Relative and absolute paths

public extension String {
    var isAbsolutePath: Bool {
        return hasPrefix("/")
    }
    
    var isRelativePath: Bool {
        return !isAbsolutePath
    }
    
    var absolutePath: String {
        guard isRelativePath else {
            return self
        }
        
        return FileManager().currentDirectoryPath.stringByAppendingPathComponent(self)
    }
    
    // return absolute standardized path for path. used for command line options
    var absoluteStandardizedPath: String {
        var path = stringByExpandingTildeInPath
        if isRelativePath {
            path = path.absolutePath
        }
        
        return path.stringByStandardizingPath
    }
}
