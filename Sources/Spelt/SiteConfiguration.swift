public struct SiteConfiguration {
    public enum Path: String {
        case config = "_config.yml"
        case destinationConfig = "_destinations.yml"
        case source = ""
        case posts = "_posts"
        case sass = "_sass"
        case layouts = "_layouts"
        case includes = "_includes"
        case assets = "assets"
        case build = "_build"
        
        // returns absolute path
        func relativeToPath(_ path: String) -> String {
            return path.stringByAppendingPathComponent(rawValue)
        }
    }
    
    static var defaultPaths: [Path] {
        return [.posts, .sass, .layouts, .includes, .assets]
    }
}
