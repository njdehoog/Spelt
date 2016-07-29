struct SiteRenderer {
    let site: Site
    
    func render() {
        renderDestinationPaths()
    }
    
    func renderDestinationPaths() {
        for var file in site.files {
            if var file = file as? FileWithMetadata, let generator = PermalinkGenerator(file: file) {
                file.destinationPath = generator.permalink
            }
            else {
                // by default, the destination path is equal to the file's path relative to the source directory
                file.destinationPath = file.relativePath(to: site.path)
            }
        }
    }
}
