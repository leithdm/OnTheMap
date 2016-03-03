//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

// MARK: - Udacity Constants

extension UdacityClient {
	
	// MARK:- Methods
	struct Methods {
		static let LoginURL = "https://www.udacity.com/api/session"
		static let signUpURL = "https://www.udacity.com/account/auth#!/signin"
		static let getPublicUserData = "https://www.udacity.com/api/users/"
	}
	
	//MARK:- Parameters
	struct Parameters {
//		static let methodParameters = [
//			"order": "-createdAt,-updatedAt",
//			"limit": 100,
//		]
	}
	
	//MARK:- HTTP Header Fields
	struct HTTPParameters {
//		static let ParseAPIKeyHeader = "X-Parse-Application-Id"
//		static let ParseAppIDHeader = "X-Parse-REST-API-Key"
	}
}