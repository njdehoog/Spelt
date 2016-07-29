public struct SiteRenderer {
    public let site: Site
    
    public func render() throws {
        renderDestinationPaths()
        try renderContents()
    }
    
    private func renderDestinationPaths() {
        for file in site.files {
            if let file = file as? FileWithMetadata, let generator = PermalinkGenerator(file: file) {
                file.destinationPath = generator.permalink
            }
            else {
                // by default, the destination path is equal to the file's path relative to the source directory
                file.destinationPath = file.relativePath(to: site.path)
            }
        }
    }
    
    private func renderContents() throws {
        try renderTemplates()
    }
    
    private func renderTemplates() throws {
        for case let file as FileWithMetadata in site.files {
            let renderer = TemplateRenderer(templatesPath: nil, includesPath: SiteConfiguration.Path.Includes.rawValue, metadata: site.metadata)
            do {
                try renderer.renderFileContents(file)
            }
            catch {
                throw Error(filePath: file.path, underlyingError: error)
            }
        }
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
    
    init(site: Site)
    func render()
}

