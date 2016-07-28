import XCTest
import Foundation
@testable import Spelt

class SiteReaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let fixturesPath = NSString(string:"~/Projects/Spelt/framework/Tests/Spelt/Fixtures").expandingTildeInPath
        let sampleProjectPath = fixturesPath.pathByAppending
        
        print(fixturesPath)
    }
    
    func testThatItReadsDocuments() {
        let fixturesPath = NSString(string:"~/Projects/Spelt/framework/Tests/Spelt/Fixtures").expandingTildeInPath
        XCTAssertEqual(fixturesPath, "nope")
    }
}
