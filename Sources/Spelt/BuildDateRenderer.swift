struct BuildDateRenderer: Renderer {
    let site: Site
    
    func render() throws {
        site.metadata["time"] = .date(Date())
    }
}
