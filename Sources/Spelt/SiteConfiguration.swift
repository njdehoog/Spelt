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