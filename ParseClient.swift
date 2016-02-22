//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
	
	//MARK:- global variables for a session
	
	//shared singleton instance of the Parse Client
	static let sharedInstance = ParseClient()
	
	//current user logged in
	var currentStudent: Student?
	
	//student mediaURL
	var mediaURL: String?
	
	//student already posted to the map?
	var studentAlreadyPosted: Bool? = false
	
	//array of students
	var students : [Student]?
	
	//is the student already on the map
	var onTheMap : Bool?
	
	//NSURLSession variable
	let session: NSURLSession
	
	
	//MARK: - lifecycle method
	override init() {
		session = NSURLSession.sharedSession()
		super.init()
	}
	
	
	//MARK: - get student location
	
	func getStudentLocations(completionHandlerForGet: (result: AnyObject!, error: NSError?) -> Void) {
		
		let methodParameters = ParseClient.Parameters.methodParameters
		
		let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Methods.StudentLocationURL + escapedParameters(methodParameters))!)
		request.addValue(ParseClient.Keys.ParseAppId, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAppIDHeader)
		request.addValue(ParseClient.Keys.ParseAPIKey, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAPIKeyHeader)
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
			
			self.parseStudentLocation(data, completionHandler: completionHandlerForGet)
		}
		task.resume()
	}
	
	
	//MARK: - parse student location
	
	func parseStudentLocation(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		var parsedStudentLocation: AnyObject!
		do  {
			parsedStudentLocation = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
			if let students = parsedStudentLocation["results"] as? [[String: AnyObject]] {
				completionHandler(result: students, error: nil)
				return
			}
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Error retrieving the 'results' key"]
			completionHandler(result: nil, error: NSError(domain: "parseStudentLocation", code: 1, userInfo: userInfo))
		}
	}
	
	//MARK: - post a student location
	
	func postStudentLocation(student: Student?, completionHandler:(completed: Bool?,errorString: String?) -> Void ){
		if student == nil {
			completionHandler(completed: false, errorString: "Invalid student data")
			return
		}
		if let uniqueKey = student!.uniqueKey, firstName = student!.firstName, lastName = student!.lastName, mapString = student!.mapString, mediaURL = student!.mediaURL, latitude = student!.latitude, longitude = student!.longitude{
			let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Methods.StudentLocationURL)!)
			request.HTTPMethod = "POST"
			request.addValue(ParseClient.Keys.ParseAppId, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAPIKeyHeader)
			request.addValue(ParseClient.Keys.ParseAPIKey, forHTTPHeaderField: ParseClient.HTTPParameters.ParseAppIDHeader)
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.HTTPBody = "{\"uniqueKey\" : \"\(uniqueKey)\", \"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\",\"mapString\" : \"\(mapString)\", \"mediaURL\" : \"\(mediaURL)\", \"latitude\" : \(latitude), \"longitude\" : \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
			
			let task = session.dataTaskWithRequest(request) {
				(data, response, error) in
				if let error = error {
					completionHandler(completed: false, errorString: error.localizedDescription)
					return
				}
				if let data = data {
					self.parsePostStudentRequest(data: data, completionHandler: completionHandler)
				} else {
					completionHandler(completed: false, errorString: "Unable to post student data")
				}
			}; task.resume()
		}
	}
	
	
	func parsePostStudentRequest(data data: NSData, completionHandler:(completed: Bool?,errorString: String?) -> Void) {
		do{
			if let parsedData =
				try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]{
					if let _ = parsedData["objectId"] as? String{
						completionHandler(completed: true, errorString: nil)
						return
					}
					completionHandler(completed: false, errorString: "Unable to add location")
			} else {
				completionHandler(completed: false, errorString: "Unable to add location")
			}
		} catch let error as NSError{
			completionHandler(completed: false, errorString: "Error adding location: \(error.localizedDescription)")
		}
	}
	
	
	
	//MARK: - create a URL from the parameters
	
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