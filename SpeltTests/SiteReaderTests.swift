import XCTest
@testable import SpeltKit

class SiteReaderTests: XCTestCase {
    
    var sampleProjectPath: String {
        // TODO: find a way to link to project directory, or copy fixtures to build folder
        let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
        return fixturesPath.stringByAppendingPathComponent("test-site")
    }
    
    var siteReader: SiteReader?
    
    override func setUp() {
        super.setUp()
        
        siteReader = SiteReader(sitePath: sampleProjectPath)
    }
    
    func testThatItReadsStaticFiles() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.staticFiles.filter({ $0.fileName == "static.html" }).count, 1)
    }
    
    func testThatItReadsPosts() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.posts.count, 4)
    }
    
    func testThatItReadsPostContents() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.posts.first?.contents, "Hello world")
    }
    
    func testThatItReadsPostCategory() {
        let site = try! siteReader!.read()
        let post = site.posts.filter({ $0.fileName == "hello-world.md" }).first!
        XCTAssertEqual(post.categories, ["new"])
    }
    
    func testThatItReadsPostCategories() {
        let site = try! siteReader!.read()
        let post = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        XCTAssertEqual(post.categories, ["writing", "markup"])
    }
    
    func testThatItReadsPages() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.documents.filter({ $0.fileName == "about.md" }).count, 1)
    }
    
    func testThatItReadsPageFromSubfolder() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.documents.filter({ $0.fileName == "info.html" }).count, 1)
    }
    
    func testThatItSkipsDirectoriesPrefixedWithUnderscore() {
        let site = try! siteReader!.read()
        for file in site.files {
            let relativePath = file.relativePath(to: site.path)
            XCTAssertFalse(relativePath.hasPrefix("_layouts"))
        }
    }
    
    func testThatItSkipsFilesPrefixedWithUnderscore() {
        let site = try! siteReader!.read()
        for file in site.files {
            XCTAssertFalse(file.fileName == "_config.yml")
        }
    }
    
    func testThatItReadsFrontMatterForPage() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.documents.first?.metadata, ["layout": "page"])
    }
    
    func testThatItReadsFrontMatterForPost() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.posts.first?.metadata, ["layout": "post", "date": "2016-07-29 09:39:21 +0200", "title": "Hello World", "categories": ["new"]])
    }
    
    func testThatItReadsConfigFile() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.metadata["title"], "My Blog")
    }
}
