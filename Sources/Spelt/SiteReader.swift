import Foundation

public struct SiteConfiguration {
    public enum Path: String {
        case Config = "_config.yml"
        case DestinationConfig = "_destinations.yml"
        case Source = ""
        case Posts = "_posts"
        case Sass = "_sass"
        case Layouts = "_layouts"
        case Includes = "_includes"
        case Assets = "assets"
        case Build = "_build"
    }
    
    static var defaultPaths: [Path] {
        return [.Posts, .Sass, .Layouts, .Includes, .Assets]
    }
}

public struct SiteReader {
    public enum Error: ErrorType {
        case DirectoryNotFound
    }
    
    let sitePath: String
    
    // TODO: init with SiteConfiguration?
    init(path: String) {
        self.sitePath = path
    }
    
    func read() throws -> Site {
        let fileManager = NSFileManager()
        guard let enumerator = fileManager.enumeratorAtURL(NSURL(fileURLWithPath: sitePath), includingPropertiesForKeys:nil, options: .SkipsHiddenFiles, errorHandler: nil) else {
            throw Error.DirectoryNotFound
        }
        
        var staticFiles = [StaticFile]()
        var posts = [Post]()
        var documents = [Document]()
        for element in enumerator {
            guard let url = element as? NSURL, let path = url.path where pathIsExcluded(path) == false else {
                continue
            }
            
            var isDirectory: ObjCBool = false
            if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) && !isDirectory {
                let stringContents = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                if let contents = stringContents where pathIsPost(path) {
                    let post = Post(path: path, contents: contents)
                    posts.append(post)
                }
                else if let contents = stringContents where stringContainsFrontMatter(contents) {
                    let document = Document(path: path, contents: contents)
                    documents.append(document)
                }
                else {
                    let file = StaticFile(path: path)
                    staticFiles.append(file)
                }
            }
        }

        return Site(path: sitePath, posts: posts, staticFiles: staticFiles, documents: documents)
    }
    
    // MARK: private
    
    func pathIsPost(path: String) -> Bool {
        let postsPath = sitePath.stringByAppendingPathComponent(SiteConfiguration.Path.Posts.rawValue)
        return path.isSubpath(ofPath: postsPath)
    }
    
    func pathIsExcluded(path: String) -> Bool {
        let relativePath = path.pathRelativeToPath(sitePath)
        
        // the _posts directory has special status and is not excluded
        // FIXME: should posts directory not start with an underscore?
        if relativePath.isSubpath(ofPath: SiteConfiguration.Path.Posts.rawValue) {
            return false
        }
        
        // exclude directories/files starting with an underscore
        for component in relativePath.pathComponents {
            if component.hasPrefix("_") {
                return true
            }
        }
        
        return false
    }
    
    func stringContainsFrontMatter(string: String) -> Bool {
        let matches = Document.frontMatterRegex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
        return matches.count > 0
    }
}
