struct PaginationRenderer: Renderer {
    let site: Site
    
    func render() throws {
        guard let maxItemsPerPage = site.maxItemsPerPage else {
            return
        }
        
        for file in site.filesWithMetadata {
            // only paginate index files
            guard let destinationPath = file.destinationPath , destinationPath.lastPathComponent == "index.html" else {
                continue
            }
            
            let items = site.posts.map({ $0 as FileWithMetadata }).sorted(by: Site.defaultFileSorting)
            
            func pathForPage(withIndex index: Int) -> String {
                guard index > 0 else {
                    return "/\(destinationPath)"
                }
                let path = destinationPath.stringByDeletingLastPathComponent
                let destinationPath = path.stringByAppendingPathComponent("\(index)").stringByAppendingPathComponent(destinationPath.lastPathComponent)
                return destinationPath
            }
            
            func URLForPage(withIndex index: Int) -> String {
                guard index > 0 else {
                    return file.URLString
                }
                let path = destinationPath.stringByDeletingLastPathComponent
                let URL = "/" + path.stringByAppendingPathComponent("\(index)")
                return URL
            }
            
            let numPages = Int(ceil(Double(items.count) / Double(maxItemsPerPage)))
            for index in 0..<numPages {
                let startIndex = index * maxItemsPerPage
                let endIndex = min(startIndex + maxItemsPerPage, items.count)
                let slice = Array(items[startIndex..<endIndex])
                var paginatorData: [String: Metadata] = ["posts": Metadata(files: slice), "page": .int(index + 1), "total_pages": .int(numPages)]
                paginatorData["per_page"] = .int(maxItemsPerPage)
                paginatorData["total_items"] = .int(items.count)
                paginatorData["multiple_pages"] = .bool(numPages > 1)
                if index + 1 < numPages {
                    paginatorData["next_page"] = .int(index + 2)
                    paginatorData["next_page_path"] = .string(URLForPage(withIndex: index + 1))
                }
                if index > 0 {
                    paginatorData["previous_page"] = .int(index)
                    paginatorData["previous_page_path"] = .string(URLForPage(withIndex: index - 1))
                }
                
                if index > 0 {
                    let pageDocument = Document(path: file.path, contents: file.contents, metadata: file.metadata)
                    pageDocument.destinationPath = pathForPage(withIndex: index)
                    pageDocument.metadata["paginator"] = .dictionary(paginatorData)
                    site.documents.append(pageDocument)
                }
                else {
                    if file.metadata == Metadata.none {
                        file.metadata = Metadata.dictionary([:])
                    }
                    
                    file.metadata["paginator"] = .dictionary(paginatorData)
                }
            }
        }
    }
}

extension Site {
    var maxItemsPerPage: Int? {
        return metadata["paginate"]?.intValue
    }
}
