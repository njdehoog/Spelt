import XCTest
@testable import Spelt

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
    
    override func setUp() {
        super.setUp()
        
        try! SiteRenderer(site: site).render()
    }
    
    func testThatBuildDirectoryIsRemoved() {
        try! SiteBuilder(site: site, buildPath: buildPath).build()
        let fileManager = NSFileManager()
        XCTAssertFalse(fileManager.fileExistsAtPath(buildPath))
    }
    
}
