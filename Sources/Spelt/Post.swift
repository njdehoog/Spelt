// TODO: should Post just be a Document which belongs to posts collection by default?
public final class Post: File {
    public let path: String
    public var contents: String
    
    public init(path: String, contents: String = "") {
        self.path = path
        self.contents = contents
    }
}

public protocol File {
    var path: String { get }
}

extension File {
    var fileName: String {
        return path.lastPathComponent
    }
    
    func relativePath(to basePath: String) -> String {
        return path.pathRelativeToPath(basePath)
    }
}


