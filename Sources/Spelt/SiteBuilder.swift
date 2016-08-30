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
        
        
        for document in site.documents {
            guard let relativeDestinationPath = document.destinationPath else {
                continue
            }
            
            let destinationPath = buildPath.stringByAppendingPathComponent(relativeDestinationPath)
            try document.contents.writeToFile(destinationPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        
        for post in site.posts {
            guard let relativeDestinationPath = post.destinationPath else {
                continue
            }
            
            let destinationPath = buildPath.stringByAppendingPathComponent(relativeDestinationPath)
            if relativeDestinationPath.pathComponents.count > 1 {
                try fileManager.createDirectoryAtPath(destinationPath.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            }
            
            try post.contents.writeToFile(destinationPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
    }
}

