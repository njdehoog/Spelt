public final class Site {
    public let path: String
    public let posts: [Post]
    public let staticFiles: [StaticFile]
    public let documents: [Document]
    public let metadata: Metadata
    
    var files: [File] {
        var files = [File]()
        files.appendContentsOf(posts.map({ $0 as File }))
        files.appendContentsOf(staticFiles.map({ $0 as File }))
        files.appendContentsOf(documents.map({ $0 as File }))
        return files
    }
    
    public init(path: String, posts: [Post], staticFiles: [StaticFile], documents: [Document]) {
        self.path = path
        self.posts = posts
        self.staticFiles = staticFiles
        self.documents = documents
        
        // FIXME: load metadata from _config.yml
        self.metadata = [:]
    }
}
