struct ExcerptRenderer: Renderer {
    let site: Site
    
    func render() throws {
        for post in site.posts {
            // do not overwrite excerpt property if it already exists
            guard post.metadata["excerpt"] == nil else {
                continue
            }
            
            // match first double newline and return everything before that
            let paragraphRegex = try NSRegularExpression(pattern: "^(.*?)(\n\n|$)", options: [.CaseInsensitive, .DotMatchesLineSeparators])
            if let excerpt = paragraphRegex.stringForFirstMatch(post.contents, options: NSMatchingOptions(), rangeAtIndex: 1) {
                // render markdown in excerpt
                let rendered = try MarkdownConverter().convert(excerpt)
                post.metadata["excerpt"] = .String(rendered)
            }
        }
    }
}