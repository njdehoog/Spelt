import XCTest
@testable import Spelt

class SiteReaderTests: XCTestCase {
    
    var sampleProjectPath: String {
        // TODO: find a way to link to project directory, or copy fixtures to build folder
        let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
        return fixturesPath.stringByAppendingPathComponent("test-site")
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testThatItReadsStaticFiles() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.staticFiles.filter({ $0.fileName == "index.html" }).count, 1)
    }
    
    func testThatItReadsPosts() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.posts.count, 1)
    }
    
    func testThatItReadsPostContents() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.posts.first?.contents, "Hello world")
    }
    
    func testThatItReadsPages() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.documents.filter({ $0.fileName == "about.md" }).count, 1)
    }
    
    func testThatItSkipsDirectoriesPrefixedWithUnderscore() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        for file in site.files {
            let relativePath = file.relativePath(to: site.path)
            XCTAssertFalse(relativePath.hasPrefix("_layouts"))
        }
    }
    
    func testThatItSkipsFilesPrefixedWithUnderscore() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        for file in site.files {
            XCTAssertFalse(file.fileName == "_config.yml")
        }
    }
    
    func testThatItReadsFrontMatterForPage() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.documents.first?.metadata, ["layout": "page"])
    }
    
    func testThatItReadsFrontMatterForPost() {
        let reader = SiteReader(path: sampleProjectPath)
        let site = try! reader.read()
        XCTAssertEqual(site.posts.first?.metadata, ["layout": "post"])
    }
}
