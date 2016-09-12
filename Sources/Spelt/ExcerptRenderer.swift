struct ExcerptRenderer: Renderer {
    let site: Site
    
    func render() throws {
        for file in site.filesWithMetadata {
            // do not overwrite excerpt property if it already exists
            guard file.metadata["excerpt"] == nil else {
                continue
            }
            
            let paragraphRegex = try NSRegularExpression(pattern: "<p>(.*?)</p>", options: [.CaseInsensitive, .DotMatchesLineSeparators])
            if let excerpt = paragraphRegex.stringForFirstMatch(file.contents, options: NSMatchingOptions(), rangeAtIndex: 1) {
                file.metadata["excerpt"] = .String(excerpt)
            }
        }
    }
}