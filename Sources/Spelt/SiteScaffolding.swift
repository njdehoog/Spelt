import SwiftYAML

// FIXME: use SiteBuilder to create scaffolding

public struct SiteScaffolding {
    let path: String
    
    enum Error: ErrorType, CustomStringConvertible {
        case DirectoryExists(String)
        
        var description: String {
            switch self {
            case .DirectoryExists(let path):
                return "File exists at path: \(path). Use --force option to overwrite."
            }
        }
    }
    
    public init(path: String) {
        self.path = path
    }
    
    public func create(force: Bool) throws {
//        try createSiteDirectory(force)
//        try createFiles([.Index, .WelcomePost])
        
        let post = Document(scaffold: ScaffoldFile.WelcomePost)
        let site = Site(path: path, posts: [], staticFiles: [], documents: [post], metadata: Metadata.None)
        let siteBuilder = SiteBuilder(site: site, buildPath: path)
        try siteBuilder.build()
        
        try createConfigFile()
    }
    
    public func createSiteDirectory(force: Bool) throws {
        if NSFileManager().fileExistsAtPath(path) {
            if force {
                try NSFileManager().removeItemAtPath(path)
            }
            else {
                throw Error.DirectoryExists(path)
            }
        }
        
        try NSFileManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func createConfigFile() throws {
        
        let settings = SettingsScaffold() { settings in
            settings.add(("title", "My Blog Title"))
            settings.add(("paginate", "5"))
        }
        
        print(settings.description)
        
        let contents = "# Site settings\n\(settings.description)"
        
        let configFilePath = SiteConfiguration.Path.Config.relativeToPath(path)
        try contents.writeToFile(configFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    private func createFiles(files: [ScaffoldFile]) throws {
        for file in files {
            let filePath = path.stringByAppendingPathComponent(file.relativePath)
            try file.description.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        }
    }
}


struct SettingsScaffold {
    struct Setting: CustomStringConvertible {
        let key: String
        let value: String
        
        var description: String {
            return "\(key): \(value)"
        }
    }
    
    var settings = [Setting]()
    
    init(_ block: (inout SettingsScaffold) -> Void) {
        block(&self)
    }
    
    mutating func add(setting: (key: String, value: String)) {
        let setting = Setting(key: setting.key, value: setting.value)
        settings.append(setting)
    }
}

extension SettingsScaffold: CustomStringConvertible {
    var description: String {
        return settings.map({ $0.description }).joinWithSeparator("\n")
    }
}

enum ScaffoldFile {
    case Index
    case WelcomePost
    
    var relativePath: String {
        switch self {
        case .Index:
            return "index.html"
        case .WelcomePost:
            return "_posts/welcome.md"
        }
    }
}

extension ScaffoldFile: CustomStringConvertible {
    var description: String {
        switch self {
        case .Index:
            return  "---\n" +
                    "---\n" +
                    "{% for post in site.posts %}" +
                    "{{ post.title }}" +
                    "{% endfor %}"
        case .WelcomePost:
            return  "---\n" +
                    "title: Welcome!" +
                    "---\n" +
                    "# Welcome to Spelt"
        }
    }
}

extension Document {
    convenience init(scaffold: ScaffoldFile) {
        self.init(path: scaffold.relativePath, contents: scaffold.description)
        self.destinationPath = self.path
    }
}
