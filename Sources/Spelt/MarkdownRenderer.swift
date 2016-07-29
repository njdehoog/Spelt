import SwiftHoedown

func htmlFromMarkdown(markdown: String) -> String? {
    return Hoedown.renderHTMLForMarkdown(markdown, extensions: [.Tables, .FootNotes, .AutoLinkURLs, .FencedCodeBlocks, .Quote, .NoIntraEmphasis, .StrikeThrough])
}