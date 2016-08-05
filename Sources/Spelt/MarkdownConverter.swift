import SwiftHoedown

struct MarkdownConverter: Converter {
    enum Error: ErrorType {
        case ConversionError
    }
    
    let outputPathExtension: String = "html"
    
    func matches(pathExtension: String) -> Bool {
        return ["md", "markdown"].contains(pathExtension)
    }
    
    func convert(content: String) throws -> String {
        guard let html = MarkdownConverter.htmlFromMarkdown(content) else {
            throw Error.ConversionError
        }
        return html
    }
    
    static func htmlFromMarkdown(markdown: String) -> String? {
        return Hoedown.renderHTMLForMarkdown(markdown, extensions: [.Tables, .FootNotes, .AutoLinkURLs, .FencedCodeBlocks, .Quote, .NoIntraEmphasis, .StrikeThrough])
    }
}