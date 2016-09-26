/**
 * Creates collections based on categories and assigns them to site metadata
 */

struct CollectionRenderer: Renderer {
    static let defaultSortingKey = "date"
    
    let site: Site
    
    func render() throws {
        let categoryNames = site.filesWithMetadata.flatMap({ $0.categories })
        
        site.metadata["collections"] = Metadata.array(categoryNames.map({ Metadata.string($0) }))
        
        for categoryName in categoryNames {
            let sortedFiles = site.filesInCategory(categoryName).sorted(by: Site.defaultFileSorting)
            site.metadata[categoryName] = Metadata(files: sortedFiles)
        }
        
        // posts are in "posts" collection by default
        let sortedPosts = site.posts.map({ $0 as FileWithMetadata }).sorted(by: Site.defaultFileSorting)
        site.metadata["posts"] = Metadata(files: sortedPosts)
    }
}

extension Site {
    public static func defaultFileSorting(_ first: FileWithMetadata, second: FileWithMetadata) -> Bool {
        guard let firstDate = first.metadata["date"], let secondDate = second.metadata["date"] else {
            return false
        }
        
        return firstDate > secondDate
    }
    
    public func filesInCategory(_ categoryName: String) -> [FileWithMetadata] {
        return filesWithMetadata.filter() { file in
            return file.categories.contains(categoryName)
        }
    }
}
