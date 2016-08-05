import Foundation
import SwiftYAML

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
    
        // returns absolute path
        func relativeToPath(path: String) -> String {
            return path.stringByAppendingPathComponent(rawValue)
        }
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
                guard let stringContents = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding) where FrontMatterReader.stringContainsFrontMatter(stringContents) else {
                    let file = StaticFile(path: path)
                    staticFiles.append(file)
                    continue
                }
                
                if pathIsPost(path) {
                    let post = try FileReader<Post>(path: path, contents: stringContents).read()
                    posts.append(post)
                }
                else {
                    let document = try FileReader<Document>(path: path, contents: stringContents).read()
                    documents.append(document)
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
}

struct FileReader<T: FileWithMetadata> {
    let path: String
    let contents: String
    
    func read() throws -> T {
        let metadata = try FrontMatterReader.frontMatterForString(contents).metadata
        let strippedContents = contents.stringByReplacingFrontMatter("")
        return T(path: path, contents: strippedContents, metadata: metadata)
    }
}

struct FrontMatterReader {
    static let frontMatterPattern = "^---.*?[\r\n]*(.*?[\r\n]+)---[\r\n]*"
    static let frontMatterRegex = try! NSRegularExpression(pattern: frontMatterPattern, options: .DotMatchesLineSeparators)
    
    enum Error: ErrorType {
        case NoFrontMatterDetected
        case ParseError(ErrorType)
    }
    
    static func stringContainsFrontMatter(string: String) -> Bool {
        let matches = frontMatterRegex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
        return matches.count > 0
    }
    
    static func frontMatterForString(string: String) throws -> YAMLValue {
        if let match = frontMatterRegex.stringForFirstMatch(string, options: NSMatchingOptions(), rangeAtIndex: 1) {
            do {
                return try YAML.load(match)
            }
            catch {
                throw Error.ParseError(error)
            }
        }
        
        throw Error.NoFrontMatterDetected
    }
}

extension String {
    func stringByReplacingFrontMatter(replacementString: String) -> String {
        let regex = try! NSRegularExpression(pattern: FrontMatterReader.frontMatterPattern, options: .DotMatchesLineSeparators)
        return regex.stringByReplacingMatchesInString(self, options:.Anchored, range: NSMakeRange(0, self.characters.count), withTemplate: replacementString)
    }
}
