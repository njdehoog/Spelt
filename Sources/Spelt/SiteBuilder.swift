import Foundation

public struct SiteBuilder {
    let site: Site
    let buildPath: String
    
    private let fileManager = NSFileManager()
    
    func build() throws {
        try SiteRenderer(site: site).render()
        try cleanBuildDirectory()
        try createBuildDirectory()
        try writeFiles()
    }
    
    private func cleanBuildDirectory() throws {
        // delete build directory if it already exists
        var isDirectory: ObjCBool = false
        let directoryExists = fileManager.fileExistsAtPath(buildPath, isDirectory: &isDirectory)
        if directoryExists && isDirectory {
            try fileManager.removeItemAtPath(buildPath)
        }
    }
    
    private func createBuildDirectory() throws {
        try self.fileManager.createDirectoryAtPath(self.buildPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func writeFiles() throws {
        for file in site.files {
            guard let relativeDestinationPath = file.destinationPath else {
                continue
            }

            let destinationPath = buildPath.stringByAppendingPathComponent(relativeDestinationPath)
            
            // create subdirectories if required
            if relativeDestinationPath.pathComponents.count > 1 {
                try fileManager.createDirectoryAtPath(destinationPath.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            }
            
            if file is StaticFile {
                try fileManager.copyItemAtPath(file.path, toPath: destinationPath)
            }
            else if let file = file as? FileWithMetadata {
                try file.contents.writeToFile(destinationPath, atomically: true, encoding: NSUTF8StringEncoding)
            }
        }
    }
}

