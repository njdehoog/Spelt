import SwiftHoedown

public final class Site {
    var documents: [Document]
    
    public init() {
        documents = []
    }
    
    public var html: String? {
        let markdown = "# Header 1"
        let html = Hoedown.renderHTMLForMarkdown(markdown)
        return html
    }
}
