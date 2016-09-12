/**
 * Creates collections based on categories and assigns them to site metadata
 */

struct CollectionRenderer: Renderer {
    static let defaultSortingKey = "date"
    
    let site: Site
    
    func render() throws {
        let categoryNames = site.filesWithMetadata.flatMap({ $0.categories })
        
        site.metadata["collections"] = Metadata.Array(categoryNames.map({ Metadata.String($0) }))
        
        for categoryName in categoryNames {
            let sortedFiles = site.filesInCategory(categoryName).sort(Site.defaultFileSorting)
            site.metadata[categoryName] = Metadata(files: sortedFiles)
        }
        
        // posts are in "posts" collection by default
        let sortedPosts = site.posts.map({ $0 as FileWithMetadata }).sort(Site.defaultFileSorting)
        site.metadata["posts"] = Metadata(files: sortedPosts)
    }
}

extension Site {
    public static func defaultFileSorting(first: FileWithMetadata, second: FileWithMetadata) -> Bool {
        return first.metadata["date"] > second.metadata["date"]
    }
    
    public func filesInCategory(categoryName: String) -> [FileWithMetadata] {
        return filesWithMetadata.filter() { file in
            return file.categories.contains(categoryName)
        }
    }
}