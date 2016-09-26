import SwiftHoedown

struct MarkdownConverter: Converter {
    enum ConversionError: Error {
        case conversionError
    }
    
    let outputPathExtension = "html"
    
    func matches(_ pathExtension: String) -> Bool {
        return ["md", "markdown"].contains(pathExtension)
    }
    
    func convert(_ content: String) throws -> String {
        guard let html = MarkdownConverter.htmlFromMarkdown(content) else {
            throw ConversionError.conversionError
        }
        return html
    }
    
    static func htmlFromMarkdown(_ markdown: String) -> String? {
        return Hoedown.renderHTMLForMarkdown(markdown, extensions: [.Tables, .FootNotes, .AutoLinkURLs, .FencedCodeBlocks, .Quote, .NoIntraEmphasis, .StrikeThrough])
    }
}
