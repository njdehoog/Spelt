import XCTest
@testable import Spelt

class SpeltTests: XCTestCase {
    
    func testSite() {
        XCTAssertNotNil(Site())
    }
    
    func testMarkdown() {
        XCTAssertEqual(Site().html!, "<h1>Header 1</h1>\n")
    }
}

