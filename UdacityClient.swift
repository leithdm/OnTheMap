//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
	
	//MARK:- properties
	
	//singleton instance of UdacityClient
	static let sharedInstance = UdacityClient()
	
	//NSURLSession variable
	let session: NSURLSession
	
	//MARK: - lifecycle method
	override init() {
		session = NSURLSession.sharedSession()
		super.init()
	}

	
	//MARK: - login
	func login(username: String, password: String, completionHandlerForLogin: (result: [String: AnyObject]?, error: String?) -> Void) {
		let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Methods.LoginURL)!)
	
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) { data, response, error in
			
			func sendError(error: String) {
				print(error)
				completionHandlerForLogin(result: nil, error: error)
			}
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				sendError("There was an error with your request. Please check your internet connection.")
				return
			}
			
			/* GUARD: Was there any data returned? */
			guard let data = data else {
				sendError("No data was returned from the server. Please contact Udacity.")
				return
			}
			
			let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
			
			self.parseLoginRequest(data: newData, completionHandlerForLogin: completionHandlerForLogin)
		}
		task.resume()
	}
	
	
	
 // MARK: - Helper Methods
	
	//login parser
	func parseLoginRequest(data data: NSData, completionHandlerForLogin: (result: [String: AnyObject]?, error: String?) -> Void) {
		do {
			let parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
			
			guard let data = parsedData else {
				completionHandlerForLogin(result: nil, error: "Error parsing data from the network.")
				return
			}
			
			guard let account = data["account"] else {
				completionHandlerForLogin(result: nil, error: "Invalid username/password combination")
				return
			}
			
			guard let registered = account["registered"] as? Bool where registered == true, let key = account["key"] as? String else {
				completionHandlerForLogin(result: nil, error: "User not registered")
				return
			}
			
			let accountDetails: [String: AnyObject] = ["key": key, "registered": registered]
			completionHandlerForLogin(result: accountDetails, error: nil)
			
		} catch {
			completionHandlerForLogin(result: nil, error: "Error logging in")
		}
	}
}
