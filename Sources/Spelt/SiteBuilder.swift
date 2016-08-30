public struct SiteBuilder {
    let site: Site
    let buildPath: String
    
    private let fileManager = NSFileManager()
    
    func build() throws {
        try SiteRenderer(site: site).render()
        try cleanBuildDirectory()
    }
    
    private func cleanBuildDirectory() throws {
        // delete build directory if it already exists
        var isDirectory: ObjCBool = false
        let directoryExists = fileManager.fileExistsAtPath(buildPath, isDirectory: &isDirectory)
        if directoryExists && isDirectory {
            try fileManager.removeItemAtPath(buildPath)
        }
    }
}

