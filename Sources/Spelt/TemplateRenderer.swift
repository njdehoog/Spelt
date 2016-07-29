import PathKit

struct TemplateRenderer {
    enum TemplateRenderingError: ErrorType {
        case TemplatesPathUndefined
    }
    
    let templatesPath: String?
    let includesPath: String
    let metadata: Metadata
    
    private var defaultContext: Context {
        var contextDict = metadata.rawValue as! [String: Any]
        contextDict["loader"] = TemplateLoader(paths: [Path(includesPath)])
        return Context(dictionary: contextDict)
    }
    
    // only renders file contents. ignores template name metadata
    func renderFileContents(file: FileWithMetadata) throws {
        let context = defaultContext
        context.push(file.metadata.rawValue as? [Swift.String: Any])
        
        let template = Template(templateString: file.contents)
        do {
            let rendered = try template.render(context, namespace: Namespace.defaultNamespace())
            file.contents = rendered
        }
        catch {
            throw SiteRenderer.Error(filePath: file.path, lineNumber: nil, underlyingError: error)
        }
        
        context.pop()
    }
    
    // renders file contents recursively into defined template
    func renderTemplate(file: FileWithMetadata) throws {
        
        guard let templateName = file.metadata.templateName else {
            // if no template name is defined, rendering stops here
            return
        }
        
        try renderFileWithTemplate(file, templateName: templateName)
    }
    
    private func renderFileWithTemplate(file: FileWithMetadata, templateName: String) throws {
        guard let templatesPath = templatesPath else {
            throw TemplateRenderingError.TemplatesPathUndefined
        }
        
        let templatePath = Path(templatesPath) + Path(templateName.stringByAppendingPathExtension("html")!)
        
        let context = defaultContext
        context.push(file.metadata.rawValue as? [Swift.String: Any])
        
        do {
            let template = try Template(path: templatePath)
            let rendered = try template.render(context, namespace: Namespace.defaultNamespace())
            let contents = rendered.stringByReplacingFrontMatter("")
            file.contents = contents
            
            context.pop()
            
            if let renderedFileMetadata = try? FrontMatterReader.frontMatterForString(rendered).metadata, let templateName = renderedFileMetadata.templateName {
                // append file metadata to template file metadata
                file.metadata = renderedFileMetadata + file.metadata
                try renderFileWithTemplate(file, templateName: templateName)
            }
        }
        catch let error as SiteRenderer.Error {
            // method can throw recursively. make sure we only wrap the underlying error once.
            throw error
        }
        catch {
            throw SiteRenderer.Error(filePath: templatePath.description, lineNumber: nil, underlyingError: error)
        }
    }
}

extension Metadata {
    public var rawValue: Any {
        switch self {
        case .None:
            return ""
        case .String(let string):
            return string
        case .Bool(let bool):
            return bool
        case .Int(let int):
            return int
        case .Double(let double):
            return double
        case .Date(let date):
            return date
        case .File(let file):
            return file.metadata.rawValue
        case .Array(let array):
            var raw: [Any] = []
            for element in array {
                raw.append(element.rawValue)
            }
            return raw
        case .Dictionary(let dictionary):
            var boxed: [Swift.String: Any] = [:]
            for (k, v) in dictionary {
                boxed[k] = v.rawValue
            }
            return boxed
        }
    }
}

extension Metadata {
    var templateName: Swift.String? {
        if let metaString = self["layout"] {
            if case .String(let string) = metaString {
                return string
            }
        }
        return nil
    }
}