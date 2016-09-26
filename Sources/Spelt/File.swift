import Foundation

public protocol File: class {
    var path: String { get }
    
    // destinationPath is relative to build directory
    var destinationPath: String? { get set }
}

extension File {
    var fileName: String {
        return path.lastPathComponent
    }
    
    func relativePath(to basePath: String) -> String {
        return path.pathRelativeToPath(basePath)
    }
}

public protocol FileWithMetadata: File {
    var contents: String { get set }
    var metadata: Metadata { get set }
    
    init(path: String, contents: String, metadata: Metadata) throws
}

extension FileWithMetadata {
    var date: Date? {
        if let dateString = metadata["date"]?.stringValue, let myDate = YAMLDateFormatter.dateFromString(dateString) {
            return myDate
        }
        
        // fallback to filename
        let dateRegex = try! NSRegularExpression(pattern: "^[0-9]{4}-[0-9]{2}-[0-9]{2}", options: [])
        if let dateString = dateRegex.stringForFirstMatch(fileName, options: .anchored) {
            return YAMLDateFormatter.dateFromString(dateString)
        }
        
        return nil
    }
    
    var URLString: String {
        guard let destinationPath = destinationPath else {
            return ""
        }
        
        let permalink = destinationPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if permalink.lastPathComponent == "index.html" {
            // if path points to an index.html file, don't include this in permalink
            return "/" + permalink.stringByDeletingLastPathComponent
        }
        return "/" + permalink
    }

    // this is the payload for rendering file in layout
    var payload: [String: Any] {
        var properties: Metadata = [:];
        properties["url"] = .string(URLString)
        properties["contents"] = Metadata.string(contents)
        properties["content"] = Metadata.string(contents)
        
        if let date = date {
            properties["date"] = Metadata.date(date)
        }
        
        // workaround for better Jekyll compatability. include all properties under page
        var combined = metadata + properties
        combined["page"] = combined
        
        return combined.rawValue as! [String: Any]
    }
}

extension FileWithMetadata {
    public var categories: [String] {
        if let categories = metadata["categories"]?.arrayValue {
            return categories.map({ $0.stringValue! })
        }
        
        return []
    }
}

