import Foundation

public struct SiteBuilder {
    let site: Site
    let buildPath: String
    
    private let fileManager = FileManager()
    
    public init(site: Site, buildPath: String) {
        self.site = site
        self.buildPath = buildPath
    }
    
    public func build() throws {
        try cleanBuildDirectory()
        try createBuildDirectory()
        try writeFiles()
    }
    
    private func cleanBuildDirectory() throws {
        // delete build directory if it already exists
        var isDirectory: ObjCBool = false
        let directoryExists = fileManager.fileExists(atPath: buildPath, isDirectory: &isDirectory)
        if directoryExists && isDirectory.boolValue {
            try fileManager.removeItem(atPath: buildPath)
        }
    }
    
    private func createBuildDirectory() throws {
        try self.fileManager.createDirectory(atPath: buildPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func writeFiles() throws {
        for file in site.files {
            guard let relativeDestinationPath = file.destinationPath else {
                continue
            }

            let destinationPath = buildPath.stringByAppendingPathComponent(relativeDestinationPath)
            
            // create subdirectories if required
            if relativeDestinationPath.pathComponents.count > 1 {
                try fileManager.createDirectory(atPath: destinationPath.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            }
            
            if file is StaticFile {
                try fileManager.copyItem(atPath: file.path, toPath: destinationPath)
            }
            else if let file = file as? FileWithMetadata {
                try file.contents.write(toFile: destinationPath, atomically: true, encoding: String.Encoding.utf8)
            }
        }
    }
}

