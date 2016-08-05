public struct SiteRenderer {
    public let site: Site
        
    public func render() throws {
        try PermalinkRenderer(site: site).render()
        try TemplateRenderer(site: site, type: .InPlace).render()
    }
}

extension SiteRenderer {
    public struct Error: ErrorType {
        public let filePath: String
        public let lineNumber: Int?
        public let underlyingError: ErrorType
        
        init(filePath: String, lineNumber: Int? = nil, underlyingError: ErrorType) {
            self.filePath = filePath
            self.lineNumber = lineNumber
            self.underlyingError = underlyingError
        }
    }
}

protocol Renderer {
    var site: Site { get }
    
    func render() throws
}

