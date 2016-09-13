public struct SiteScaffolding {
    let destinationPath: String
    let templatePath: String
    let fileManager = NSFileManager()
    
    enum Error: ErrorType, CustomStringConvertible {
        case DirectoryExists(String)
        
        var description: String {
            switch self {
            case .DirectoryExists(let path):
                return "File exists at path: \(path). Use --force option to overwrite."
            }
        }
    }
    
    public init(destinationPath: String, templatePath: String) {
        self.destinationPath = destinationPath
        self.templatePath = templatePath
    }
    
    public func create(force: Bool) throws {
        do {
            try fileManager.copyItemAtPath(templatePath, toPath: destinationPath)
        }
        catch NSCocoaError.FileWriteFileExistsError {
            if force {
                try fileManager.removeItemAtPath(destinationPath)
                
                // try again, this time not forced
                try create(false)
            }
            else {
                throw Error.DirectoryExists(destinationPath)
            }
        }
    }
}