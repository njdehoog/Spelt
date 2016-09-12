/**
 * Creates collections based on categories and assigns them to site metadata
 */

struct CollectionRenderer: Renderer {
    let site: Site
    
    func render() throws {
        var collections = [String: [FileWithMetadata]]()
        
        for file in site.filesWithMetadata {
            var categories = file.categories ?? [String]()
            if file is Post {
                // posts are in "posts" collection by default
                categories.append("posts")
            }
            
            for category in categories {
                var filesInCategory = collections[category] ?? [FileWithMetadata]()
                filesInCategory.append(file)
                collections[category] = filesInCategory
            }
        }
        
        var siteMetadata = site.metadata
        siteMetadata["collections"] = Metadata.Array(collections.keys.map({ Metadata.String($0) }))
        
        for (category, files) in collections {
            siteMetadata[category] = Metadata(files: files)
        }
        
        site.metadata = siteMetadata
    }
}