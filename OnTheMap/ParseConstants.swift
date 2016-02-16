//
//  TMDBConstants.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

// MARK: - TMDBClient (Constants)

extension ParseClient {
	
	// MARK:- Key Constants
	struct Keys {
		static let ParseAppId : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	// MARK:- Methods
	struct Methods {
		static let StudentLocationURL = "https://api.parse.com/1/classes/StudentLocation"
	}
	
	//MARK:- Parameters
	struct Parameters {
		static let methodParameters = [
			"order": "-createdAt,-updatedAt",
			"limit": 100,
		]
	}
	
	//MARK:- HTTP Header Fields
	struct HTTPParameters {
		static let ParseAPIKeyHeader = "X-Parse-Application-Id"
		static let ParseAppIDHeader = "X-Parse-REST-API-Key"
	}
	
}