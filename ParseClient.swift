//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
	
	//shared instance of Parse Client
	static let sharedInstance = ParseClient()
	
	//shared session
	var session = NSURLSession.sharedSession()
	
	
	//MARK: - get Student Locations
	
	func getStudentLocations(completionHandlerForGet: (result: AnyObject!, error: NSError?) -> Void) {
		
		let methodParameters = ParseClient.Parameters.methodParameters
		
		let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Methods.StudentLocationURL + escapedParameters(methodParameters))!)
		request.addValue(ParseClient.Keys.ParseAPIKey, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAPIKeyHeader)
		request.addValue(ParseClient.Keys.ParseAppId, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAppIDHeader)
		request.HTTPMethod = "GET"
		
		//create task
		let task = session.dataTaskWithRequest(request) { data, response, error in
			
			
			func sendError(error: String) {
				print(error)
				let userInfo = [NSLocalizedDescriptionKey : error]
				completionHandlerForGet(result: nil, error: NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo))
			}
			
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				sendError("There was an error with your request: \(error)")
				return
			}
			
			/* GUARD: Did we get a successful 2XX response? */
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				sendError("Your request returned a status code other than 2xx!")
				return
			}
			
			/* GUARD: Was there any data returned? */
			guard let data = data else {
				sendError("No data was returned by the request!")
				return
			}
			
			self.parseLocation(data, completionHandler: completionHandlerForGet)
		}
		task.resume()
	}
	
	
	//MARK: - parseLocation
	
	func parseLocation(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		
		var parsedLocation: AnyObject!
		
		do  {
			parsedLocation = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Error retrieving the 'results' key"]
			completionHandler(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
		}
		if let students = parsedLocation["results"] as? [[String: AnyObject]] {
			completionHandler(result: students, error: nil)
			return
		}
	}
	
	
	// MARK:- create a URL from parameters
	private func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
		
		let components = NSURLComponents()
		components.scheme = ParseClient.Keys.ParseAppId
		
		
		components.queryItems = [NSURLQueryItem]()
		
		for (key, value) in parameters {
			let queryItem = NSURLQueryItem(name: key, value: "\(value)")
			components.queryItems!.append(queryItem)
		}
		
		return components.URL!
	}
	
	//MARK: - escaped Parameters method
	func escapedParameters(parameters: [String : AnyObject]) -> String {
		var urlVars = [String]()
		for (key, value) in parameters {
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			/* FIX: Replace spaces with '+' */
			let replaceSpaceValue = escapedValue!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
			/* Append it */
			urlVars += [key + "=" + "\(replaceSpaceValue)"]
		}
		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
	}
	
}