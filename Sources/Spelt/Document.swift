// Any file which contains front matter and is not a blog post is considered a document
public final class Document: FileWithMetadata {
    public let path: String
    public var destinationPath: String?
    public var contents: String
    public var metadata: Metadata
    
    public init(path: String, contents: String = "", metadata: Metadata = .none) {
        self.path = path
        self.contents = contents
        self.metadata = metadata
    }
}
