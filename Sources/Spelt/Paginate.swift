struct PaginationRenderer: Renderer {
    let site: Site
    
    func render() throws {
        guard let maxItemsPerPage = site.maxItemsPerPage else {
            return
        }
        
        for file in site.filesWithMetadata {
            // only paginate index files
            guard let destinationPath = file.destinationPath where destinationPath.lastPathComponent == "index.html" else {
                continue
            }
            
            let items = site.posts.map({ $0 as FileWithMetadata })
            
            func pathForPage(withIndex index: Int) -> String {
                guard index > 0 else {
                    return "/\(file.destinationPath)"
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
                var paginatorData: [String: Metadata] = ["posts": Metadata(files: slice), "page": .Int(index + 1), "total_pages": .Int(numPages)]
                paginatorData["per_page"] = .Int(maxItemsPerPage)
                paginatorData["total_items"] = .Int(items.count)
                paginatorData["multiple_pages"] = .Bool(numPages > 1)
                if index + 1 < numPages {
                    paginatorData["next_page"] = .Int(index + 2)
                    paginatorData["next_page_path"] = .String(URLForPage(withIndex: index + 1))
                }
                if index > 0 {
                    paginatorData["previous_page"] = .Int(index)
                    paginatorData["previous_page_path"] = .String(URLForPage(withIndex: index - 1))
                }
                
                if index > 0 {
                    let pageDocument = Document(path: file.path, contents: file.contents, metadata: file.metadata)
                    pageDocument.destinationPath = pathForPage(withIndex: index)
                    pageDocument.metadata["paginator"] = .Dictionary(paginatorData)
                    site.documents.append(pageDocument)
                }
                else {
                    if file.metadata == Metadata.None {
                        file.metadata = Metadata.Dictionary([:])
                    }
                    
                    file.metadata["paginator"] = .Dictionary(paginatorData)
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