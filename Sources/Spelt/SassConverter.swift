import SwiftSass

struct SassConverter: Converter {
    let outputPathExtension = "css"
    let site: Site
    
    func matches(pathExtension: String) -> Bool {
        return ["sass", "scss"].contains(pathExtension)
    }
    
    func convert(content: String) throws -> String {
        var options = SassOptions()
        options.includePath = SiteConfiguration.Path.Sass.relativeToPath(site.path)
        return try Sass.compile(content, options: options)
    }
}