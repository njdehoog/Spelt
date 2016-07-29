import XCTest
@testable import Spelt

class SiteReaderTests: XCTestCase {
    
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
    }
    
    func testThatItReadsStaticFiles() {
        XCTAssertEqual(site.staticFiles.filter({ $0.fileName == "index.html" }).count, 1)
    }
    
    func testThatItReadsPosts() {
        XCTAssertEqual(site.posts.count, 2)
    }
    
    func testThatItReadsPostContents() {
        XCTAssertEqual(site.posts.first?.contents, "Hello world")
    }
    
    func testThatItReadsPages() {
        XCTAssertEqual(site.documents.filter({ $0.fileName == "about.md" }).count, 1)
    }
    
    func testThatItSkipsDirectoriesPrefixedWithUnderscore() {
        for file in site.files {
            let relativePath = file.relativePath(to: site.path)
            XCTAssertFalse(relativePath.hasPrefix("_layouts"))
        }
    }
    
    func testThatItSkipsFilesPrefixedWithUnderscore() {
        for file in site.files {
            XCTAssertFalse(file.fileName == "_config.yml")
        }
    }
    
    func testThatItReadsFrontMatterForPage() {
        XCTAssertEqual(site.documents.first?.metadata, ["layout": "page"])
    }
    
    func testThatItReadsFrontMatterForPost() {
        XCTAssertEqual(site.posts.first?.metadata, ["layout": "post", "date": "2016-07-29 09:39:21 +0200"])
    }
}
