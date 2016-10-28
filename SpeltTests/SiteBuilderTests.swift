import XCTest
@testable import SpeltKit

class SiteBuilderTests: XCTestCase {
    
    var buildPath: String {
        return sampleProjectPath.stringByAppendingPathComponent("_build")
    }
    
    lazy var site: Site = { [unowned self] in
        return try! SiteReader(sitePath: self.sampleProjectPath).read()
        }()
    
    var siteBuilder: SiteBuilder?
    
    override func setUp() {
        super.setUp()
        
        // render site before building
        try! SiteRenderer(site: site).render()
        siteBuilder = SiteBuilder(site: site, buildPath: buildPath)
    }
    
    func testThatBuildDirectoryIsRemoved() {
        // create test file in build directory to check if it is removed by build command
        try! FileManager().createDirectory(atPath: buildPath, withIntermediateDirectories: true, attributes: nil)
        let testFilePath = buildPath.stringByAppendingPathComponent("test.txt")
        try! "hello world".write(toFile: testFilePath, atomically: true, encoding: String.Encoding.utf8)
        
        try! siteBuilder?.build()
        XCTAssertFalse(FileManager().fileExists(atPath: testFilePath))
    }
    
    func testThatBuildDirectoryIsCreated() {
        try! siteBuilder?.build()
        XCTAssertTrue(FileManager().fileExists(atPath: buildPath))
    }
    
    func testThatStaticFileIsCopied() {
        try! siteBuilder?.build()
        
        let staticHTMLFile = site.staticFiles.filter({ $0.fileName == "static.html" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(staticHTMLFile.destinationPath!)
        XCTAssertTrue(FileManager().fileExists(atPath: filePath))
    }
    
    func testThatStaticFileIsCopiedToSubfolder() {
        try! siteBuilder?.build()
        
        let peacockImageFile = site.staticFiles.filter({ $0.fileName == "peacock.jpeg" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(peacockImageFile.destinationPath!)
        XCTAssertTrue(FileManager().fileExists(atPath: filePath))
    }
    
    func testThatDocumentIsWritten() {
        try! siteBuilder?.build()
        
        let aboutPage = site.documents.filter({ $0.fileName == "about.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(aboutPage.destinationPath!)
        XCTAssertTrue(FileManager().fileExists(atPath: filePath))
    }
    
    func testThatDocumentIsWrittenToSubfolder() {
        try! siteBuilder?.build()
        
        let aboutPage = site.documents.filter({ $0.fileName == "info.html" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(aboutPage.destinationPath!)
        XCTAssertTrue(FileManager().fileExists(atPath: filePath))
    }
    
    func testThatPostIsWritten() {
        try! siteBuilder?.build()
        
        let markdownPost = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(markdownPost.destinationPath!)
        XCTAssertTrue(FileManager().fileExists(atPath: filePath))
    }
    
    func testThatPostContentIsCorrectlyWritten() {
        try! siteBuilder?.build()
        
        let markdownPost = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(markdownPost.destinationPath!)
        XCTAssertEqual(markdownPost.contents, try? String(contentsOfFile: filePath))
    }
}
