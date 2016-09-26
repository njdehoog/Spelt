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
    }
}
