public final class Post: FileWithMetadata {
    public enum InitializationError: Error {
        case missingDate
    }
    
    public let path: String
    public var destinationPath: String?
    public var contents: String
    public var metadata: Metadata
    
    public init(path: String, contents: String = "", metadata: Metadata) throws {
        self.path = path
        self.contents = contents
        self.metadata = metadata
        
        guard self.date != nil else {
            throw InitializationError.missingDate
        }
    }
}

extension Post: Equatable {}

public func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.path == rhs.path && lhs.destinationPath == rhs.destinationPath
}
