extension String {

    // strip all HTML tags from the string
    func stripHTML() -> String {
        return stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
}