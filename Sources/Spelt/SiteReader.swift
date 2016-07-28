import Foundation

public struct SiteReader {
    public enum Error: ErrorType {
        case DirectoryNotFound
    }
    
    let siteURL: NSURL
    
    init(siteURL: NSURL) {
        self.siteURL = siteURL
    }
    
    func read(excludePaths: [String] = []) throws -> Site {
        let fileManager = NSFileManager()
        guard let enumerator = fileManager.enumeratorAtURL(self.siteURL, includingPropertiesForKeys:nil, options: .SkipsHiddenFiles, errorHandler: nil) else {
            throw Error.DirectoryNotFound
        }
        
        var staticFiles = [StaticFile]()
        for element in enumerator {
            guard let url = element as? NSURL, let path = url.path where pathIsExcluded(path, excludePaths: excludePaths) == false else {
                continue
            }
            
            var isDirectory: ObjCBool = false
            if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) && !isDirectory {
                // TODO: check for front matter
                let file = StaticFile(path: path)
                staticFiles.append(file)
            }
        }

        return Site(staticFiles: staticFiles)
    }
    
    // MARK: private
    
    func pathIsExcluded(path: String, excludePaths: [String]) -> Bool {
        for excludePath in excludePaths {
            if path.isSubpath(ofPath: excludePath) {
                return true
            }
        }
        
        return false
    }
}
