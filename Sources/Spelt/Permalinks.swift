import Foundation

struct PermalinkRenderer: Renderer {
    let site: Site
    
    func render() throws {
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
        case .literal(let literal):
            if literal.pathExtension.isEmpty {
                return literal.stringByAppendingPathComponent(PermalinkGenerator.indexFileName)
            }
            else {
                return literal
            }
        case .date(let date):
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let lastPathComponent = file.fileName.stringByDeletingPathExtension.slugalizedString.stringByAppendingPathExtension("html")
            return String.pathWithComponents([String(format: "%02d", components.year!), String(format: "%02d", components.month!), String(format: "%02d", components.day!), lastPathComponent!])
        case .format(_):
            fatalError("Custom format for permalink not yet implemented")
        }
    }
}

extension PermalinkGenerator {
    init?(file: FileWithMetadata) {
        self.file = file
        if let permalink = file.metadata["permalink"]?.stringValue {
            type = .literal(permalink)
        }
        else if let date = file.date , file is Post {
            type = .date(date)
        }
        else {
            return nil
        }
    }
}

enum PermalinkType {
    case date(Foundation.Date)
    case literal(String)
    case format(String) // TODO: implement custom formats
}

extension String {
    var slugalizedString: String {
        var slug = self
        let separator = "-"
        
        // Remove all non-ASCII characters
        let nonASCIICharsRegex = try! NSRegularExpression(pattern: "[^\\x00-\\x7F]+", options: [])
        slug = nonASCIICharsRegex.stringByReplacingMatches(in: slug, options: [], range: NSMakeRange(0, slug.count), withTemplate: "")
        
        // Turn non-slug characters into separators
        let nonSlugCharactersRegex = try! NSRegularExpression(pattern: "[^a-z0-9\\-_\\+]+", options: [.caseInsensitive])
        slug = nonSlugCharactersRegex.stringByReplacingMatches(in: slug, options: [], range: NSMakeRange(0, slug.count), withTemplate: separator)
        
        // No more than one of the separator in a row
        let repeatingSeparatorsRegex = try! NSRegularExpression(pattern: "\(separator){2,}", options: [])
        slug = repeatingSeparatorsRegex.stringByReplacingMatches(in: slug, options: [], range: NSMakeRange(0, slug.count), withTemplate: separator)
        
        // Remove leading/trailing separator
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: separator))
        
        // Make lowercase
        return slug.lowercased()
    }
}
