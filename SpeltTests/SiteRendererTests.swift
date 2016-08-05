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
        
        try! SiteRenderer(site: site).render()
    }
    
    // MARK: destination paths
    
    func testThatDestinationPathIsCorrectForPost() {
        let post = site.posts.filter({ $0.fileName == "hello-world.md" }).first
        XCTAssertEqual(post?.destinationPath, "2016/07/29/hello-world.html")
    }
    
    func testThatDestinationPathIsCorrectForPage() {
        let page = site.documents.filter({ $0.fileName == "about.md" }).first
        XCTAssertEqual(page?.destinationPath, "about.html")
    }
    
    func testThatDestinationPathIsCorrectForStaticFile() {
        let page = site.staticFiles.filter({ $0.fileName == "index.html" }).first
        XCTAssertEqual(page?.destinationPath, "index.html")
    }
    
    // MARK: templating
    
    func testThatTemplateTagIsRendered() {
        let post = site.posts.filter({ $0.fileName == "templating.md" }).first
        XCTAssertEqual(post?.contents, "<p>Spelt</p>\n")
    }
    
    // MARK: markdown conversion
    
    func testThatMarkdownIsConverted() {
        let post = site.posts.filter({ $0.fileName == "markdown.md" }).first
        XCTAssertEqual(post?.contents, "<h1>Header 1</h1>\n")
        XCTAssertEqual(post?.destinationPath?.pathExtension, "html")
    }
}
