import XCTest
@testable import SpeltKit

class SiteReaderTests: XCTestCase {
    
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
        let post = site.posts.first { $0.fileName == "hello-world.md" }
        XCTAssertEqual(post?.contents, "Hello world")
    }
    
    func testThatItReadsPostCategory() {
        let site = try! siteReader!.read()
        let post = site.posts.first { $0.fileName == "hello-world.md" }
        XCTAssertEqual(post?.categories, ["new"])
    }
    
    func testThatItReadsPostCategories() {
        let site = try! siteReader!.read()
        let post = site.posts.first { $0.fileName == "markdown.md" }
        XCTAssertEqual(post?.categories, ["writing", "markup"])
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
        let document = site.documents.first { $0.fileName == "info.html" }
        XCTAssertEqual(document?.metadata, ["layout": "page"])
    }
    
    func testThatItReadsFrontMatterForPost() {
        let site = try! siteReader!.read()
        let post = site.posts.first { $0.fileName == "hello-world.md" }
        XCTAssertEqual(post?.metadata, ["layout": "post", "date": "2016-07-29 09:39:21 +0200", "title": "Hello World", "categories": ["new"]])
    }
    
    func testThatItReadsConfigFile() {
        let site = try! siteReader!.read()
        XCTAssertEqual(site.metadata["title"], "My Blog")
    }
}
