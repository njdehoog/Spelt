public struct SiteBuilder {
    let site: Site
    
    func build() throws {
        try SiteRenderer(site: site).render()
    }
}

