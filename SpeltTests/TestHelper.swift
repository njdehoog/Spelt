import XCTest

extension XCTestCase {
    var sampleProjectPath: String {
        let bundleResourcePath = Bundle(for: type(of: self)).resourcePath
        return bundleResourcePath!.stringByAppendingPathComponent("test-site")
    }
}
