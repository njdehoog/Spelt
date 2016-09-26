//
//  PostTests.swift
//  Spelt
//
//  Created by Niels de Hoog on 30/08/16.
//
//

import XCTest
@testable import SpeltKit

class PostTests: XCTestCase {
    
    func testThatItRequiresDate() {
        XCTAssertThrowsError(try Post(path: "", contents: "", metadata: Metadata.none)) { error in
            XCTAssertEqual(error as? Post.InitializationError, Post.InitializationError.missingDate)
        }
    }
}
