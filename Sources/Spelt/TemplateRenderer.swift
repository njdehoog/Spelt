import PathKit

struct TemplateRenderer: Renderer {
    enum RendererType {
        case InPlace
        case UsingTemplate
    }
    
    private var defaultContext: Context {
        var contextDict = site.metadata.rawValue as! [String: Any]
        contextDict["loader"] = TemplateLoader(paths: [Path(SiteConfiguration.Path.Includes.rawValue)])
        return Context(dictionary: contextDict)
    }
    
    let site: Site
    let type: RendererType
    
    init(site: Site, type: RendererType = .InPlace) {
        self.site = site
        self.type = type
    }
    
    func render() throws {
        for case let file as FileWithMetadata in site.files {
            switch type {
            case .InPlace:
                try renderInPlace(file)
            case .UsingTemplate:
                try renderUsingTemplate(file)
            }
        }
    }
    
    // only renders file contents. ignores template name metadata
    private func renderInPlace(file: FileWithMetadata) throws {
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
    private func renderUsingTemplate(file: FileWithMetadata) throws {
        guard let templateName = file.metadata.templateName else {
            // if no template name is defined, rendering stops here
            return
        }
        
        try renderFileWithTemplate(file, templateName: templateName)
    }
    
    private func renderFileWithTemplate(file: FileWithMetadata, templateName: String) throws {
        let templatesPath = SiteConfiguration.Path.Layouts.relativeToPath(site.path)
        let templatePath = Path(templatesPath) + Path(templateName.stringByAppendingPathExtension("html")!)
        
        let context = defaultContext
        context.push(file.payload.rawValue as? [Swift.String: Any])
        
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
    var templateName: Swift.String? {
        if let metaString = self["layout"] {
            if case .String(let string) = metaString {
                return string
            }
        }
        return nil
    }
}