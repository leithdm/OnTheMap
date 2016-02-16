//
//  OnTheMapTests.swift
//  OnTheMapTests
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import XCTest
@testable import OnTheMap

class OnTheMapTests: XCTestCase {
	
	let mapViewController = MapViewController()
	
    
    func testParseData() {
		mapViewController.parseData()
		XCTAssertNotNil(mapViewController.annotations, "annotation array should not be empty!")
    }

    
}
