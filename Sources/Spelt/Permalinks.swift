struct PermalinkRenderer: Renderer {
    let site: Site
    
    func render() {
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
}

struct PermalinkGenerator {
    static let indexFileName = "index.html"
    
    let type: PermalinkType
    let file: File
    
    var permalink: String {
        switch type {
        case .Literal(let literal):
            if literal.pathExtension.isEmpty {
                return literal.stringByAppendingPathComponent(PermalinkGenerator.indexFileName)
            }
            else {
                return literal
            }
        case .Date(let date):
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year, .Month, .Day], fromDate: date)
            let lastPathComponent = file.fileName.stringByDeletingPathExtension.slugalizedString.stringByAppendingPathExtension("html")
            return String.pathWithComponents([String(format: "%02d", components.year), String(format: "%02d", components.month), String(format: "%02d", components.day), lastPathComponent!])
        case .Format(_):
            fatalError("Custom format for permalink not yet implemented")
        }
    }
}

extension PermalinkGenerator {
    init?(file: FileWithMetadata) {
        self.file = file
        if let permalink = file.metadata["permalink"]?.stringValue {
            type = .Literal(permalink)
        }
        else if let date = file.date where file is Post {
            type = .Date(date)
        }
        else {
            return nil
        }
    }
}

enum PermalinkType {
    case Date(NSDate)
    case Literal(String)
    case Format(String) // TODO: implement custom formats
}

extension String {
    var slugalizedString: String {
        var slug = self
        let separator = "-"
        
        // Remove all non-ASCII characters
        let nonASCIICharsRegex = try! NSRegularExpression(pattern: "[^\\x00-\\x7F]+", options: [])
        slug = nonASCIICharsRegex.stringByReplacingMatchesInString(slug, options: [], range: NSMakeRange(0, slug.characters.count), withTemplate: "")
        
        // Turn non-slug characters into separators
        let nonSlugCharactersRegex = try! NSRegularExpression(pattern: "[^a-z0-9\\-_\\+]+", options: [.CaseInsensitive])
        slug = nonSlugCharactersRegex.stringByReplacingMatchesInString(slug, options: [], range: NSMakeRange(0, slug.characters.count), withTemplate: separator)
        
        // No more than one of the separator in a row
        let repeatingSeparatorsRegex = try! NSRegularExpression(pattern: "\(separator){2,}", options: [])
        slug = repeatingSeparatorsRegex.stringByReplacingMatchesInString(slug, options: [], range: NSMakeRange(0, slug.characters.count), withTemplate: separator)
        
        // Remove leading/trailing separator
        slug = slug.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: separator))
        
        // Make lowercase
        return slug.lowercaseString
    }
}