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
        for file in site.staticFiles {
            guard let relativeDestinationPath = file.destinationPath else {
                continue
            }
            
            // copy static files to build directory
            let destinationPath = buildPath.stringByAppendingPathComponent(relativeDestinationPath)
            try fileManager.copyItemAtPath(file.path, toPath: destinationPath)
        }
        
//        var files = self.files
//        var metadata = self.metadata
//        for plugin in self.plugins {
//            if cancelled {
//                throw Error.Cancelled
//            }
//            (files, metadata) = try plugin(files, metadata, self)
//        }
//        
//        for file in files {
//            let path = buildPath.stringByAppendingPathComponent(file.destinationPath)
//            if path.pathComponents.count > 1 {
//                try self.fileManager.createDirectoryAtPath(path.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
//            }
//            file.contents.writeToFile(path, atomically: true)
//        }
    }
}

