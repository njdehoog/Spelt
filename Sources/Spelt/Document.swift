// Any file which contains front matter and is not a blog post is considered front matter
public final class Document: File {
    public let path: String
    var contents: String
    
    init(path: String, contents: String = "") {
        self.path = path
        self.contents = contents
    }
}

// front matter
extension Document {
    static let frontMatterPattern = "^---.*?[\r\n]*(.*?[\r\n]+)---[\r\n]*"
    static let frontMatterRegex = try! NSRegularExpression(pattern: frontMatterPattern, options: .DotMatchesLineSeparators)
}