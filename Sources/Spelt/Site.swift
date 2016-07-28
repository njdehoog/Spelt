import SwiftHoedown

public final class Site {
//    var documents: [Document]
    public let staticFiles: [StaticFile]
    
    public init(staticFiles: [StaticFile]) {
//        documents = []
        self.staticFiles = staticFiles
    }
    
    public var html: String? {
        let markdown = "# Header 1"
        let html = Hoedown.renderHTMLForMarkdown(markdown)
        return html
    }
}
