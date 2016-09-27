import SwiftYAML

public struct SiteScaffolding {
    let destinationPath: String
    let templatePath: String
    let fileManager = FileManager()
    
    enum WriteError: Error, CustomStringConvertible {
        case directoryExists(String)
        
        var description: String {
            switch self {
            case .directoryExists(let path):
                return "File exists at path: \(path). Use --force option to overwrite."
            }
        }
    }
    
    public init(destinationPath: String, templatePath: String) {
        self.destinationPath = destinationPath
        self.templatePath = templatePath
    }
    
    public func create(_ force: Bool) throws {
        do {
            try fileManager.copyItem(atPath: templatePath, toPath: destinationPath)
        }
        catch CocoaError.fileWriteFileExists {
            if force {
                try fileManager.removeItem(atPath: destinationPath)
                
                // try again, this time not forced
                try create(false)
            }
            else {
                throw WriteError.directoryExists(destinationPath)
            }
        }
        
        try replaceWelcomePost()
    }
    
    private func replaceWelcomePost() throws {
        // replace welcome post with one that is dynamically generated
        let filePath = destinationPath.stringByAppendingPathComponent("_posts/welcome.md")
        let postContents = try String(contentsOfFile: filePath).stringByReplacingFrontMatter("")
        let dateString = YAMLDateFormatter.stringFromDate(Date())
        let frontMatter: YAMLValue = ["title": "Welcome to Spelt", "layout": "post", "date": .string(dateString)]
        let generatedContents = try YAML.emit(frontMatter) + "---\n\n" + postContents
        try generatedContents.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
}
