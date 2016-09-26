import SwiftSass

struct SassConverter: Converter {
    let outputPathExtension = "css"
    let site: Site
    
    func matches(_ pathExtension: String) -> Bool {
        return ["sass", "scss"].contains(pathExtension)
    }
    
    func convert(_ content: String) throws -> String {
        var options = SassOptions()
        options.includePath = SiteConfiguration.Path.sass.relativeToPath(site.path)
        return try Sass.compile(content, options: options)
    }
}
