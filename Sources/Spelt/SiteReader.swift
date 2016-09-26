import Foundation
import SwiftYAML

public struct SiteReader {
    public enum ReadError: Error {
        case directoryNotFound
    }
    
    public let sitePath: String
    
    public init(sitePath: String) {
        self.sitePath = sitePath
    }
    
    public func read() throws -> Site {
        let fileManager = FileManager()
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: sitePath), includingPropertiesForKeys:nil, options: .skipsHiddenFiles, errorHandler: nil) else {
            throw ReadError.directoryNotFound
        }
        
        var staticFiles = [StaticFile]()
        var posts = [Post]()
        var documents = [Document]()
        for element in enumerator {
            guard let url = element as? URL, pathIsExcluded(url.path) == false else {
                continue
            }
            
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                guard let stringContents = try? String(contentsOfFile: url.path, encoding: String.Encoding.utf8) , FrontMatterReader.stringContainsFrontMatter(stringContents) else {
                    let file = StaticFile(path: url.path)
                    staticFiles.append(file)
                    continue
                }
                
                if pathIsPost(url.path) {
                    let post = try FileReader<Post>(path: url.path, contents: stringContents).read()
                    posts.append(post)
                }
                else {
                    let document = try FileReader<Document>(path: url.path, contents: stringContents).read()
                    documents.append(document)
                }
            }
        }
        
        let configFilePath = SiteConfiguration.Path.config.relativeToPath(sitePath)
        let metadata = try ConfigReader(filePath: configFilePath).read()

        return Site(path: sitePath, posts: posts, staticFiles: staticFiles, documents: documents, metadata: metadata)
    }
    
    // MARK: private
    
    func pathIsPost(_ path: String) -> Bool {
        let postsPath = sitePath.stringByAppendingPathComponent(SiteConfiguration.Path.posts.rawValue)
        return path.isSubpath(ofPath: postsPath)
    }
    
    func pathIsExcluded(_ path: String) -> Bool {
        let relativePath = path.pathRelativeToPath(sitePath)
        
        // the _posts directory has special status and is not excluded
        // FIXME: should posts directory not start with an underscore?
        if relativePath.isSubpath(ofPath: SiteConfiguration.Path.posts.rawValue) {
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
        let metadata = try FrontMatterReader.frontMatterForString(contents).metadata.normalizeCategories()
        let strippedContents = contents.stringByReplacingFrontMatter("")
        return try T(path: path, contents: strippedContents, metadata: metadata)
    }
}

extension Metadata {
    func normalizeCategories() -> Metadata {
        guard var metadataDict = dictionaryValue, let categories = categories  else {
            return self;
        }
        
        metadataDict["categories"] = Metadata.array(categories.map({ Metadata.string($0) }))
        metadataDict["category"] = nil
        return Metadata.dictionary(metadataDict)
    }
    
    private var categories: [Swift.String]? {
        if let category = self["category"]?.stringValue {
            return [category]
        }
        
        if let categories = self["categories"]?.stringValue {
            return categories.split(",").map() { $0.trim(" ") }
        }
        
        if let categories = self["categories"]?.arrayValue {
            var categoryNames: [Swift.String] = []
            for category in categories {
                guard let stringValue = category.stringValue else  {
                    return nil
                }
                categoryNames.append(stringValue)
            }
            return categoryNames
        }
        
        return nil
    }
}

struct FrontMatterReader {
    static let frontMatterPattern = "^---.*?[\r\n]*(.*?[\r\n]+)---[\r\n]*"
    static let frontMatterRegex = try! NSRegularExpression(pattern: frontMatterPattern, options: .dotMatchesLineSeparators)
    
    indirect enum ReadError: Error {
        case noFrontMatterDetected
        case parseError(Error)
    }
    
    static func stringContainsFrontMatter(_ string: String) -> Bool {
        let matches = frontMatterRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, string.characters.count))
        return matches.count > 0
    }
    
    static func frontMatterForString(_ string: String) throws -> YAMLValue {
        if let match = frontMatterRegex.stringForFirstMatch(string, options: NSRegularExpression.MatchingOptions(), rangeAtIndex: 1) {
            do {
                return try YAML.load(match)
            }
            catch {
                throw ReadError.parseError(error)
            }
        }
        
        throw ReadError.noFrontMatterDetected
    }
}

extension String {
    func stringByReplacingFrontMatter(_ replacementString: String) -> String {
        let regex = try! NSRegularExpression(pattern: FrontMatterReader.frontMatterPattern, options: .dotMatchesLineSeparators)
        return regex.stringByReplacingMatches(in: self, options:.anchored, range: NSMakeRange(0, self.characters.count), withTemplate: replacementString)
    }
}

struct ConfigReader {
    let filePath: String
    
    func read() throws -> Metadata {
        let configFileContents = try String(contentsOfFile: filePath)
        return try YAML.load(configFileContents).metadata
    }
}
