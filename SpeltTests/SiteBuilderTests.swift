import XCTest
@testable import SpeltKit

class SiteBuilderTests: XCTestCase {
    
    var sampleProjectPath: String {
        // TODO: find a way to link to project directory, or copy fixtures to build folder
        let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
        return fixturesPath.stringByAppendingPathComponent("test-site")
    }
    
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
        try! NSFileManager().createDirectoryAtPath(buildPath, withIntermediateDirectories: true, attributes: nil)
        let testFilePath = buildPath.stringByAppendingPathComponent("test.txt")
        try! "hello world".writeToFile(testFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        
        try! siteBuilder?.build()
        XCTAssertFalse(NSFileManager().fileExistsAtPath(testFilePath))
    }
    
    func testThatBuildDirectoryIsCreated() {
        try! siteBuilder?.build()
        XCTAssertTrue(NSFileManager().fileExistsAtPath(buildPath))
    }
    
    func testThatStaticFileIsCopied() {
        try! siteBuilder?.build()
        
        let indexHTMLFile = site.staticFiles.filter({ $0.fileName == "index.html" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(indexHTMLFile.destinationPath!)
        XCTAssertTrue(NSFileManager().fileExistsAtPath(filePath))
    }
    
    func testThatStaticFileIsCopiedToSubfolder() {
        try! siteBuilder?.build()
        
        let peacockImageFile = site.staticFiles.filter({ $0.fileName == "peacock.jpeg" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(peacockImageFile.destinationPath!)
        XCTAssertTrue(NSFileManager().fileExistsAtPath(filePath))
    }
    
    func testThatDocumentIsWritten() {
        try! siteBuilder?.build()
        
        let aboutPage = site.documents.filter({ $0.fileName == "about.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(aboutPage.destinationPath!)
        XCTAssertTrue(NSFileManager().fileExistsAtPath(filePath))
    }
    
    func testThatDocumentIsWrittenToSubfolder() {
        try! siteBuilder?.build()
        
        let aboutPage = site.documents.filter({ $0.fileName == "info.html" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(aboutPage.destinationPath!)
        XCTAssertTrue(NSFileManager().fileExistsAtPath(filePath))
    }
    
    func testThatPostIsWritten() {
        try! siteBuilder?.build()
        
        let markdownPost = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(markdownPost.destinationPath!)
        XCTAssertTrue(NSFileManager().fileExistsAtPath(filePath))
    }
    
    func testThatPostContentIsCorrectlyWritten() {
        try! siteBuilder?.build()
        
        let markdownPost = site.posts.filter({ $0.fileName == "markdown.md" }).first!
        let filePath = buildPath.stringByAppendingPathComponent(markdownPost.destinationPath!)
        XCTAssertEqual(markdownPost.contents, try? String(contentsOfFile: filePath))
    }
}
