extension String {

    // strip all HTML tags from the string
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
