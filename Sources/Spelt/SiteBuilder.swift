public struct SiteBuilder {
    let site: Site
    
    func build() {
        SiteRenderer(site: site).render()
    }
    
    
}

