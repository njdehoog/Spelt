public protocol File {
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
    var metadata: Metadata { get set }
    
    init(path: String, contents: String, metadata: Metadata)
}

extension FileWithMetadata {
    var date: NSDate? {
        if let dateString = metadata["date"]?.stringValue, let myDate = YAMLDateFormatter.dateFromString(dateString) {
            return myDate
        }
        
        // fallback to filename
        let dateRegex = try! NSRegularExpression(pattern: "^[0-9]{4}-[0-9]{2}-[0-9]{2}", options: [])
        if let dateString = dateRegex.stringForFirstMatch(fileName, options: .Anchored) {
            return YAMLDateFormatter.dateFromString(dateString)
        }
        
        return nil
    }
}

