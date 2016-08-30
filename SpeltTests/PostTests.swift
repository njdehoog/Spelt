//
//  PostTests.swift
//  Spelt
//
//  Created by Niels de Hoog on 30/08/16.
//
//

import XCTest
@testable import Spelt

class PostTests: XCTestCase {
    
    func testThatItRequiresDate() {
        XCTAssertThrowsError(try Post(path: "", contents: "", metadata: Metadata.None)) { error in
            XCTAssertEqual(error as? Post.Error, Post.Error.MissingDate)
        }
    }
}
