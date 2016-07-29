import XCTest
@testable import Spelt

class SiteRendererTests: XCTestCase {

    var sampleProjectPath: String {
        // TODO: find a way to link to project directory, or copy fixtures to build folder
        let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
        return fixturesPath.stringByAppendingPathComponent("test-site")
    }
    
    lazy var site: Site = { [unowned self] in
       return try! SiteReader(sitePath: self.sampleProjectPath).read()
    }()
    
    override func setUp() {
        super.setUp()
        
        SiteRenderer(site: site).render()
    }
    
    func testThatDestinationPathIsCorrectForPost() {
        let post = site.posts.filter({ $0.fileName == "hello-world.md" }).first
        XCTAssertEqual(post?.destinationPath, "2016/07/29/hello-world.html")
    }
    
    func testThatDestinationPathIsCorrectForPage() {
        let page = site.documents.filter({ $0.fileName == "about.md" }).first
        XCTAssertEqual(page?.destinationPath, "about.md")
    }
    
    func testThatDestinationPathIsCorrectForStaticFile() {
        let page = site.staticFiles.filter({ $0.fileName == "index.html" }).first
        XCTAssertEqual(page?.destinationPath, "index.html")
    }
}
