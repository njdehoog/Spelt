import XCTest
@testable import Spelt

class SiteReaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let fixturesPath = NSString(string:"~/Projects/Spelt/framework/SpeltTests/Fixtures").stringByExpandingTildeInPath
        let sampleProjectPath = (fixturesPath as NSString).stringByAppendingPathComponent("test-site")
        
        print(sampleProjectPath)
    }
    
    func testThatItReadsDocuments() {
        let fixturesPath = NSString(string:"~/Projects/Spelt/framework/Tests/Spelt/Fixtures").stringByExpandingTildeInPath
        XCTAssertEqual(fixturesPath, "nope")
    }
}
