//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
	
	static let sharedInstance = UdacityClient()
	
	func getRequest(username: String, password: String) {
	
		let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil { // Handle error…
				return
			}
			let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
			print(NSString(data: newData, encoding: NSUTF8StringEncoding))
		}
		task.resume()
		
	}
	
	
}
