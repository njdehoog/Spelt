// TODO: should Post just be a Document which belongs to posts collection by default?
public final class Post: FileWithMetadata {
    public let path: String
    public var contents: String
    public var metadata: Metadata
    
    public init(path: String, contents: String = "", metadata: Metadata) {
        self.path = path
        self.contents = contents
        self.metadata = metadata
    }
}

public protocol File {
    var path: String { get }
}

public protocol FileWithMetadata: File {
    var metadata: Metadata { get set }
    
    init(path: String, contents: String, metadata: Metadata)
}

extension File {
    var fileName: String {
        return path.lastPathComponent
    }
    
    func relativePath(to basePath: String) -> String {
        return path.pathRelativeToPath(basePath)
    }
}


