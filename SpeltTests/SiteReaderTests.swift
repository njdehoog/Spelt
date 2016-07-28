import XCTest
@testable import Spelt

class SiteReaderTests: XCTestCase {
    
    var sampleProjectPath: String {
        let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
        return fixturesPath.stringByAppendingPathComponent("test-site")
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testThatItReadsStaticFile() {
        let reader = SiteReader(siteURL: NSURL(fileURLWithPath: sampleProjectPath))
        let site = try! reader.read()
        XCTAssert(site.staticFiles.count == 1)
    }
}
