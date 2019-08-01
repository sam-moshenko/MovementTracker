//
//  NasladdinApiTests.swift
//  NasladdinApiTests
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import XCTest
import Alamofire
import RxSwift
@testable import NasladdinApi

class NasladdinApiTests: XCTestCase {
    let repository = NasladdinRepository(sessionManager: Alamofire.SessionManager.default)
    let disposeBag = DisposeBag()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPutStatus() {
        let exp = expectation(description: "response")
        exp.expectedFulfillmentCount = 2
        
        repository.setStatus(.failed).map {
            XCTAssertNotNil($0.response)
            XCTAssertEqual($0.response!.statusCode, 200)
            exp.fulfill()
        }.subscribe().disposed(by: disposeBag)
        
        repository.setStatus(.success).map {
            XCTAssertNotNil($0.response)
            XCTAssertEqual($0.response!.statusCode, 200)
            exp.fulfill()
        }.subscribe().disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 10)
    }

}
