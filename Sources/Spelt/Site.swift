public final class Site {
    public let path: String
    public var posts: [Post]
    public var staticFiles: [StaticFile]
    public var documents: [Document]
    public var metadata: Metadata
    
    var files: [File] {
        var files = [File]()
        files += posts.map({ $0 as File })
        files += staticFiles.map({ $0 as File })
        files += documents.map({ $0 as File })
        return files
    }
    
    var filesWithMetadata: [FileWithMetadata] {
        var files = [FileWithMetadata]()
        files += posts.map({ $0 as FileWithMetadata })
        files += documents.map({ $0 as FileWithMetadata })
        return files
    }
    
    public init(path: String, posts: [Post], staticFiles: [StaticFile], documents: [Document], metadata: Metadata) {
        self.path = path
        self.posts = posts
        self.staticFiles = staticFiles
        self.documents = documents
        self.metadata = metadata
    }
}

extension Site {
    var payload: [String: Any] {
        return metadata.rawValue as! [String: Any]
    }
    
    var collections: [String]? {
        return metadata["collections"]?.arrayValue?.compactMap({ $0.stringValue })
    }
}
