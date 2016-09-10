import XCTest
@testable import SpeltKit

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
        let post = site.posts.filter({ $0.fileName == "templating.md" }).first!
        XCTAssertEqual(post.contents, "<p>Spelt</p>\n")
    }
    
    func testThatItRendersSiteTitle() {
        let post = site.posts.filter({ $0.fileName == "site-title.md" }).first!
        XCTAssertEqual(post.contents, "<p>My Blog</p>\n")
    }
    
    // MARK: markdown conversion
    
    func testThatMarkdownIsConverted() {
        let post = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        XCTAssertEqual(post.contents, "<h1>Header 1</h1>\n")
    }
    
    func testThatMarkdownPathExtensionIsCorrect() {
        let post = site.posts.filter({ $0.fileName == "markdown.md" }).first
        XCTAssertEqual(post?.destinationPath?.pathExtension, "html")
    }
    
    // MARK: Sass conversion
    
    func testThatSassIsConverted() {
        let sassFile = site.documents.filter({ $0.fileName == "main.scss" }).first
        XCTAssertEqual(sassFile?.contents, ".foo {\n  width: 50%; }\n")
    }
    
    func testThatSassPathExtensionIsCorrect() {
        let sassFile = site.documents.filter({ $0.fileName == "main.scss" }).first
        XCTAssertEqual(sassFile?.destinationPath?.pathExtension, "css")
    }
    
    // MARK: layouts
    
    func testThatOutputIsPlacedInLayout() {
        let page = site.documents.filter({ $0.fileName == "about.md" }).first
        XCTAssertEqual(page?.contents, "<article><p>Sample About page</p>\n</article>")
    }
    
    // MARK: collections
    
    func testThatPostsCollectionIsRendered() {
        let indexPage = site.documents.filter({ $0.fileName == "blog.html" }).first
        let string = indexPage?.contents.containsString("hello")
        print(indexPage?.contents)
        XCTAssertNotNil(indexPage)
    }
}
